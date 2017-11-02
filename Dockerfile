FROM docker.topicusonderwijs.nl/jboss/base-jdk:8

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 11.0.0.Final
ENV WILDFLY_SHA1 0e89fe0860a87bfd6b09379ee38d743642edfcfb
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Install build tools
RUN yum install -y -q git

# Patch and build Hibernate
ARG HIBERNATE_VERSION=5.1.10
ARG HIBERNATE_BASE=$JBOSS_HOME/modules/system/layers/base/org/hibernate
ARG GRADLE_ARGS="-x checkstyleMain -x findbugsMain -x compileTestJava -x compileTestGroovy -x processTestResources -x testClasses -x findbugsTest -x test"
RUN git clone --branch $HIBERNATE_VERSION --depth 1 -c advice.detachedHead=false https://github.com/hibernate/hibernate-orm.git
COPY *.patch /tmp/
RUN cd hibernate-orm \
    && git apply -v /tmp/HHH-4959.patch /tmp/HHH-11377.patch \
    && ./gradlew hibernate-core:build hibernate-infinispan:build $GRADLE_ARGS \
    && cp hibernate-core/target/libs/hibernate-core-*.jar $HIBERNATE_BASE/main/ \
    && cp hibernate-infinispan/target/libs/hibernate-infinispan-*.jar $HIBERNATE_BASE/infinispan/main/ \
    && cd .. \    
    && rm -rf /tmp/*.patch /root/.gradle hibernate-orm

# Remove build tools
RUN yum history undo last -y -q \
    && yum clean all \
    && rm -rf /var/cache/yum

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]

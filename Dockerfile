FROM docker.topicusonderwijs.nl/jboss/base-jdk:8

# Set the WILDFLY_VERSION env variable
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
ADD ./target/wildfly.tar.gz /opt/jboss

WORKDIR /opt/jboss/wildfly/standalone
RUN mkdir log && chown jboss:jboss log
RUN mkdir data && chown jboss:jboss data
# todo: user management + logging ergens anders?
RUN chown jboss:jboss configuration
RUN chown jboss:jboss tmp

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]

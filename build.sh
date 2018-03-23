#!/bin/sh

WILDFLY_VERSION="12.0.0.Final"
export JAVA_HOME=/usr/lib/jvm/jre-openjdk

# Patch and build a fresh Wildfly 12
rm -rf wildfly
git clone --branch $WILDFLY_VERSION --depth 1 -c advice.detachedHead=false https://github.com/wildfly/wildfly.git
cd wildfly

./build.sh --batch-mode -Dmaven.repo.local=../.repository -DskipTests
cd ..

# Patch and build a new Hibernate 5.1.10
HIBERNATE_BASE="../wildfly/dist/target/wildfly-$WILDFLY_VERSION/modules/system/layers/base/org/hibernate"
rm -rf hibernate-orm
git clone --branch 5.1.10 --depth 1 -c advice.detachedHead=false https://github.com/hibernate/hibernate-orm.git
cd hibernate-orm
git apply -v ../HHH-4959.patch ../HHH-11377.patch ../HHH-12036.patch ../HHH-10677.patch
./gradlew hibernate-core:build hibernate-infinispan:build -x checkstyleMain -x findbugsMain -x compileTestJava -x compileTestGroovy -x processTestResources -x testClasses -x findbugsTest -x test
cp hibernate-core/target/libs/hibernate-core-*Final.jar $HIBERNATE_BASE/main/
cp hibernate-infinispan/target/libs/hibernate-infinispan-*Final.jar $HIBERNATE_BASE/infinispan/main/
cd ..    

# Create dist archive
cd wildfly/dist/target/wildfly-$WILDFLY_VERSION

tar -czf ../wildfly.tar.gz .

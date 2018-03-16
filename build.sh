#!/bin/sh

WILDFLY_VERSION="11.0.0.Final"

# Patch and build a fresh Wildfly 11
rm -rf wildfly
git clone --branch $WILDFLY_VERSION --depth 1 -c advice.detachedHead=false https://github.com/wildfly/wildfly.git
cd wildfly

# fix voor JGRP-2236
sed -i 's/jgroups>3.6.13.Final/jgroups>3.6.15.Final/g' pom.xml

git apply -v ../WFLY-9474.patch
git apply -v ../WFLY-9488.patch
./build.sh --batch-mode -Dmaven.repo.local=../.repository -DskipTests
cd ..

# Patch and build a new Hibernate 5.1.10
HIBERNATE_BASE="../wildfly/dist/target/wildfly-$WILDFLY_VERSION/modules/system/layers/base/org/hibernate"
rm -rf hibernate-orm
git clone --branch 5.1.10 --depth 1 -c advice.detachedHead=false https://github.com/hibernate/hibernate-orm.git
cd hibernate-orm
git apply -v ../HHH-4959.patch ../HHH-11377.patch ../HHH-12036.patch ../HHH-10677.patch
export JAVA_HOME=/usr/lib/jvm/jre-openjdk
./gradlew hibernate-core:build hibernate-infinispan:build -x checkstyleMain -x findbugsMain -x compileTestJava -x compileTestGroovy -x processTestResources -x testClasses -x findbugsTest -x test
cp hibernate-core/target/libs/hibernate-core-*Final.jar $HIBERNATE_BASE/main/
cp hibernate-infinispan/target/libs/hibernate-infinispan-*Final.jar $HIBERNATE_BASE/infinispan/main/
cd ..    

# Create dist archive
cd wildfly/dist/target/wildfly-$WILDFLY_VERSION

# patch jandex
wget -P modules/system/layers/base/org/jboss/jandex/main/ http://repo1.maven.org/maven2/org/jboss/jandex/2.0.4.Final/jandex-2.0.4.Final.jar
sed -i 's/2.0.3/2.0.4/g' modules/system/layers/base/org/jboss/jandex/main/module.xml

tar -czf ../wildfly.tar.gz .

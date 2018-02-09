#!/bin/sh
mkdir target
#docker build -f Dockerfile.build -t wildfly-dist .
docker create --name wildfly-dist-cont wildfly-dist
docker cp wildfly-dist-cont:/tmp/wildfly-11.0.0.Final.topicus1.tar.gz ./target
docker build -f Dockerfile .


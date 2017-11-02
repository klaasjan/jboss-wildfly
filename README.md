[![WildFly logo](http://design.jboss.org/wildfly/logo/final/wildfly_logo_450px.png)](http://http://wildfly.org//)
# WildFly Docker image
Docker image for WildFly project

Based on https://github.com/jboss-dockerfiles/wildfly, but includes a few backported fixes to WildFly modules.

## How to build
```
> docker build --squash .
```
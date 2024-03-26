FROM ubuntu:24.04 as build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y openjdk-11-jdk
RUN apt-get install -y git 
RUN apt-get install -y maven
ARG REPO
ARG PATH /opt/app
COPY <<EOF ./script.sh
#!/bin/bash
git clone $REPO $PATH
cd $PATH
mvn clean package
EOF
RUN sh script.sh

FROM kulbhushanmayer/tomcat:10.1.19 
COPY --from=build $PATH/target/*.war /opt/app/tomcat/webapps/ #Add maven again
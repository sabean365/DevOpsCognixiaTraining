FROM ubuntu:24:04
ARG DEBIAN_FRONTEND=noninteractive
ARG ARCHIVE_URL=https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.19/bin/apache-tomcat-10.1.19.tar.gz
ARG TOMCAT_VERSION=10.1.19
ARG USER=tomcat
ARG WORKDIR=/opt/
RUN apt-get update && apt-get install -y wget opjdk-17-jre
RUN adduser ${USER} -m -d ${WORKDIR}
USER ${USER}
WORKDIR ${WORKDIR}
RUN wget ${ARCHIVE_URL} && tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz && mv apache-tomcat-${TOMCAT_VERSION} tomcat && rm apache-tomcat-${TOMCAT_VERSION}.tar.gz
COPY tomcat-users.xml tomcat/conf/tomcat-users.xml && cp manager-context.xml tomcat/webapps/manager/META-INF/context.xml
EXPOSE 8080/TCP
CMD ["sh", "tomcat/bin/catalina.sh", "run"]
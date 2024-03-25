# Dockerfolder

## with Maven at maven.dockerfile
<img width="50" height="50" src="https://img.icons8.com/ios/50/FF0000/maven-ios.png" alt="maven-ios"/>

## Instructions to run maven.dockerfile
## maven.dockerfile is a java-app multifile which installs openjdk-11-jdk, git, and maven and creates a bash script and copys a WAR file.
```
mv maven.dockerfile Dockerfile
```
```
docker image build . -f Dockerfile -t app:1.0 --build-arg REPO=https://github.com/kmayer10/ubs-java-app.git
```
```
docker container run -d -p 8080:8080 --name tomcat app:1.0
```
## TO SCAN, IF TRIVY IS INSTALLED: USE TO SCAN FOR POTENTIAL VULNERABILITIES
#### [Trivy Documentation] (https://github.com/aquasecurity/trivy)
```
trivy image app:1.0 <image-name:version>
```
## with PSQL at psql.dockerfile
<img width="48" height="48" src="https://img.icons8.com/color/48/postgreesql.png" alt="postgreesql"/>

## with tomcat at tomcat.dockerfile and generalized with tomcat-users.xml
<img width="48" height="48" src="https://img.icons8.com/color/48/tomcat.png" alt="tomcat"/>

## Instructions to use tomcat.dockerfile to create an image
#### Run the below command to create tomcat image for version `10.1.19`
```
mv tomcat.dockerfile Dockerfile
```
```
docker image build -f Dockerfile -t tomcat:10.1.19 .
```
#### Pass below mentioned inputs as `--build-arg` to make any changes in the image
- ARCHIVE_URL       # URL to download tomcat tar file
- TOMCAT_VERSION    # Version of tomcat
- USER              # Default Application user to be used to start the tomcat process in container
- WORKDIR           # Default WORKDIR
```
docker image build -f Dockerfile -t tomcat:10.1.20 . --build-arg USER=appuser --build-arg TOMCAT_VERSION=10.1.20
```



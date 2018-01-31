FROM openjdk:8-jdk
MAINTAINER Yair Bass (yairbass@gmail.com)
VOLUME /tmp
ADD /target/spring-petclinic-2.0.0.jar spring-petclinic-2.0.0.jar
ADD /src/main/resources/db/mysql/ .
CMD java -Djava.security.egd=file:/dev/./urandom -jar ./spring-petclinic-2.0.0.jar


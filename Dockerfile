# FROM eclipse-temurin:17-jdk-jammy as base
FROM public.ecr.aws/docker/library/maven:3.9.3-amazoncorretto-17 as base
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as development
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM base as build
RUN ./mvnw package


# FROM eclipse-temurin:17-jre-jammy as production
FROM public.ecr.aws/docker/library/maven:3.9.3-amazoncorretto-17 as production
EXPOSE 8080
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]
COPY --from=build /app/target/spring-petclinic-*.jar /spring-petclinic.jar
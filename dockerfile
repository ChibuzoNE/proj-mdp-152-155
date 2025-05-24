# Stage 1: Build
FROM maven:3.8.5-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Stage 2: Runtime
FROM tomcat:9.0-jdk11
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]

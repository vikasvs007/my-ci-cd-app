# Use an official OpenJDK runtime as a parent image
FROM openjdk:11-jre-slim

# Set the working directory in the container
WORKDIR /app

# Argument for the JAR file. The Jenkinsfile will pass the correct versioned JAR name.
ARG JAR_FILE=target/my-ci-cd-app-1.0-SNAPSHOT.jar

# Copy the executable JAR file from the host to the container
COPY ${JAR_FILE} app.jar

# Make port 8080 available
EXPOSE 8080

# Run the JAR file
ENTRYPOINT ["java","-jar","/app/app.jar"]
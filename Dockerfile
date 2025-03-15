FROM alpine:latest

# Install required dependencies
RUN apk update && \
    apk add --no-cache openjdk17 maven git

# Set working directory
WORKDIR /tmp

# Clone the repository and build the application
RUN git clone https://github.com/emad-hussain/htmx-demo.git && \
    cd htmx-demo && \
    mvn clean package

# Expose application port
EXPOSE 8080

# Set working directory to the built app
WORKDIR /tmp/htmx-demo

# Command to run the Spring Boot application
CMD ["mvn", "spring-boot:run"]

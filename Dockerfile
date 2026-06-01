# Stage 1: Generate wrapper and build the application jar
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app

# Install Maven temporarily to generate the wrapper files
RUN apt-get update && apt-get install -y maven

# Copy only the configuration file first
COPY pom.xml ./

# Generate the Maven wrapper inside the container
RUN mvn wrapper:wrapper

# Download dependencies to leverage Docker cache
RUN ./mvnw dependency:go-offline -B

# Copy source code and build the application jar
COPY src ./src
RUN ./mvnw package -DskipTests -B

# Stage 2: Run the built jar file
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy the built jar from the first stage
COPY --from=build /app/target/*.jar app.jar

# Expose port 3000
EXPOSE 3000

# Execute the application
ENTRYPOINT ["java", "-jar", "app.jar"]

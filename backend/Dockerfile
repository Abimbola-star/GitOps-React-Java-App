# Multi-stage build for Java application
FROM eclipse-temurin:11-jdk AS builder

WORKDIR /app
COPY Main.java .
RUN mkdir -p com/cyat/backend
RUN javac Main.java -d .

FROM eclipse-temurin:11-jre
WORKDIR /app
COPY --from=builder /app/com /app/com
EXPOSE 8080
ENTRYPOINT ["java", "com.cyat.backend.Main"]
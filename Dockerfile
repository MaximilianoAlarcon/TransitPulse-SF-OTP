FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update && apt-get install -y awscli curl && rm -rf /var/lib/apt/lists/*

ADD https://repo1.maven.org/maven2/org/opentripplanner/otp-shaded/2.7.0/otp-shaded-2.7.0.jar /app/otp.jar

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8080

CMD ["/bin/sh", "/app/start.sh"]
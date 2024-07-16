FROM eclipse-temurin:21 AS setup
WORKDIR /app
RUN apt-get update && apt-get -y install git unzip curl wget osslsigncode && \
    wget https://download2.gluonhq.com/openjfx/22.0.1/openjfx-22.0.1_linux-x64_bin-jmods.zip && \
    unzip openjfx-22.0.1_linux-x64_bin-jmods.zip && \
    cp javafx-jmods-22.0.1/* /opt/java/openjdk/jmods && \
    rm -r javafx-jmods-22.0.1 && \
    rm -rf openjfx-22.0.1_linux-x64_bin-jmods.zip
FROM setup AS launchserver
COPY setup-docker.sh .
RUN chmod +x setup-docker.sh && \
    ./setup-docker.sh && \
    rm -rf ~/.gradle # Clear gradle cache
WORKDIR /app/data
VOLUME /app/data
EXPOSE 9274
ENTRYPOINT ["/app/start.sh"]

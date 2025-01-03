FROM eclipse-temurin:21-noble AS setup
WORKDIR /app
RUN apt-get update && apt-get -y install git unzip curl wget osslsigncode vim socat nano && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://download2.gluonhq.com/openjfx/22.0.2/openjfx-22.0.2_linux-x64_bin-jmods.zip && \
    unzip openjfx-22.0.2_linux-x64_bin-jmods.zip && \
    cp javafx-jmods-22.0.2/* /opt/java/openjdk/jmods && \
    rm -r javafx-jmods-22.0.2 && \
    rm -rf openjfx-22.0.2_linux-x64_bin-jmods.zip
FROM setup AS launchserver
COPY setup-docker.sh .
RUN chmod +x setup-docker.sh && \
    ./setup-docker.sh && \
    rm -rf ~/.gradle # Clear gradle cache
WORKDIR /app/data
VOLUME /app/data
EXPOSE 9274
ENTRYPOINT ["/app/start.sh"]

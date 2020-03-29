FROM ubuntu:18.04
RUN apt update && apt install -y curl zip \
    && rm -rf /var/lib/apt/lists/*
COPY ./script/upload_and_enable.sh ./script/upload_and_enable.sh
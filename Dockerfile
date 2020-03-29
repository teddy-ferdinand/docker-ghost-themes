FROM ubuntu:18.04
RUN apt install curl zip
COPY ./script/upload_and_enable.sh ./script/upload_and_enable.sh
# This Dockerfile downloads all the external dependencies
# tag: gringofts:dependencies
FROM ubuntu:16.04
MAINTAINER jqi1@ebay.com
WORKDIR /usr/external
COPY scripts/downloadDependencies.sh /usr/external
RUN bash downloadDependencies.sh
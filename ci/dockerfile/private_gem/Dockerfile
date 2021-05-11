# syntax = docker/dockerfile:experimental

FROM ruby:3.0 AS builder

ARG GITHUB_USERNAME
ARG GITHUB_TOKEN

ENV GITHUB_USERNAME=${GITHUB_USERNAME}
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

WORKDIR /home

# git-credential-github-token
#
# #!/bin/sh
#
# echo protocol=https
# echo host=github.com
# echo username=$GITHUB_USERNAME
# echo password=$GITHUB_TOKEN
COPY ./git-credential-github-token /usr/local/bin
RUN git config --global credential.helper github-token

COPY . .

RUN bundle install --without development test

FROM ruby:3.0

WORKDIR /home
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /home /home

CMD ["bundle", "ex", "irb"]

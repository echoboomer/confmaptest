FROM alpine:3.12.0

ENV KUBECTL_VERSION=1.17.12

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
  apk update && \
  # Install dependencies for awscli.
  apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  git \
  yq \
  # Install kubectl
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
  mv kubectl /usr/local/bin && \
  chmod +x /usr/local/bin/kubectl

COPY ./scripts /scripts

ENTRYPOINT []
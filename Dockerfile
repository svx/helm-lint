ARG KUBERNETES=1.15.7

FROM python:3.9.0-alpine3.12 as KUBEVAL_SCHEMA
ARG KUBERNETES
RUN set -eux; \
    pip install openapi2jsonschema==0.9.1; \
    mkdir -p /etc/kubeval; \
    openapi2jsonschema --expanded --kubernetes --stand-alone --strict \
        --output /etc/kubeval/v$KUBERNETES-standalone-strict \
        https://github.com/kubernetes/kubernetes/raw/v$KUBERNETES/api/openapi-spec/swagger.json

FROM alpine:3.12.1
ARG KUBERNETES
ENV KUBERNETES=$KUBERNETES
RUN apk add --no-cache \
        bash=5.0.17-r0 \
        curl=7.69.1-r1 \
        git=2.26.2-r0

ENV PS1='\u@\h:\w\$ '
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

WORKDIR /usr/local/bin
ENV HELM=3.4.1
RUN curl -fLSs https://get.helm.sh/helm-v$HELM-linux-amd64.tar.gz | tar xz linux-amd64/helm; \
    mv linux-amd64/helm .; \
    rm -rf linux-amd64

ENV HELM_DOCS=1.4.0
RUN curl -fLSs https://github.com/norwoodj/helm-docs/releases/download/v$HELM_DOCS/helm-docs_${HELM_DOCS}_Linux_x86_64.tar.gz \
        | tar xz helm-docs

ENV KUBEVAL=0.15.0
RUN curl -fLSs https://github.com/instrumenta/kubeval/releases/download/$KUBEVAL/kubeval-linux-amd64.tar.gz \
        | tar xz kubeval
ENV KUBEVAL_SCHEMA_LOCATION=file:///etc/kubeval
COPY --from=KUBEVAL_SCHEMA /etc/kubeval /etc/kubeval

COPY helm /helm
WORKDIR /src
CMD ["/helm/run.sh"]
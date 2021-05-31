FROM python:3.8.10-alpine3.13

RUN apk add --no-cache \
        bash=5.1.0-r0 \
        curl=7.77.0-r0 \
        git=2.30.2-r0
RUN pip install --no-cache-dir \
        openapi2jsonschema==0.9.1 \
        yamllint==1.26.1

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
ENV PS1='\u@\h:\w\$ '

WORKDIR /usr/local/bin
ENV HELM=3.3.4
RUN curl -fLSs https://get.helm.sh/helm-v$HELM-linux-amd64.tar.gz | tar xz linux-amd64/helm; \
    mv linux-amd64/helm .; \
    rm -rf linux-amd64; \
    helm plugin install https://github.com/chartmuseum/helm-push.git

ENV HELM_DOCS=1.5.0
RUN curl -fLSs https://github.com/norwoodj/helm-docs/releases/download/v$HELM_DOCS/helm-docs_${HELM_DOCS}_Linux_x86_64.tar.gz \
        | tar xz helm-docs

ENV KUBEVAL=0.16.1
ENV KUBEVAL_SCHEMA_DIR=/etc/kubeval
ENV KUBEVAL_SCHEMA_LOCATION=file://$KUBEVAL_SCHEMA_DIR
RUN curl -fLSs https://github.com/instrumenta/kubeval/releases/download/v$KUBEVAL/kubeval-linux-amd64.tar.gz \
        | tar xz kubeval

WORKDIR $KUBEVAL_SCHEMA_DIR
ENV KUBERNETES=1.15.7
RUN openapi2jsonschema --expanded --kubernetes --stand-alone --strict \
        --output v$KUBERNETES-standalone-strict \
        https://github.com/kubernetes/kubernetes/raw/v$KUBERNETES/api/openapi-spec/swagger.json

COPY helm /helm
WORKDIR /src
CMD ["/helm/run.sh"]

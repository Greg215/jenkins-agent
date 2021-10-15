FROM docker:latest

RUN apk --update add python3 py3-pip nodejs npm yarn\
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --upgrade awscli
RUN apk add --no-cache bash git openssh-client lftp gzip openjdk11
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/$(wget -q -O - https://storage.googleapis.com/kubernetes-release/release/stable.txt -O -)/bin/linux/amd64/kubectl -O kubectl
RUN chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
RUN mkdir -p ~/.kube
RUN node --version
RUN java --version

RUN apk add --no-cache --virtual .curl curl \
        && TRIVY_VERSION=0.18.3 \
        && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v$TRIVY_VERSION \
    && trivy -v
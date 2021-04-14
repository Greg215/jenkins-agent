FROM docker:latest

RUN apk --update add python3 py-pip \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --upgrade awscli
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/$(wget -q -O - https://storage.googleapis.com/kubernetes-release/release/stable.txt -O -)/bin/linux/amd64/kubectl -O kubectl
RUN chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
RUN mkdir -p ~/.kube
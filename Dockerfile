FROM alpine:3.19

ARG KUBECTL_VERSION=v1.29.0

RUN apk add --no-cache bash curl \
    && curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

COPY node-cordon.sh /usr/local/bin/node-cordon.sh
RUN chmod +x /usr/local/bin/node-cordon.sh

USER 1000
ENTRYPOINT ["/usr/local/bin/node-cordon.sh"]

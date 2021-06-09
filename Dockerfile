FROM curlimages/curl:7.77.0 AS downloader

ARG TARGET_OS
ARG TARGET_ARCH
ARG KUBECTL_VERSION
ARG KUSTOMIZE_VERSION

WORKDIR /downloads

RUN set -ex; \
    curl -fL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/${TARGET_OS}/${TARGET_ARCH}/kubectl -o kubectl && \
    chmod +x kubectl

RUN set -ex; \
    curl -fL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGET_OS}_${TARGET_ARCH}.tar.gz | tar xz && \
    chmod +x kustomize


# Runtime
FROM alpine:3.13.5 AS runtime

LABEL maintainer="LINE Open Source <dl_oss_dev@linecorp.com>"

COPY --from=downloader /downloads/kubectl /usr/local/bin/kubectl
COPY --from=downloader /downloads/kustomize /usr/local/bin/kustomize

ENTRYPOINT ["sh"]


# Test
FROM runtime AS test

RUN set -ex; kubectl && kustomize

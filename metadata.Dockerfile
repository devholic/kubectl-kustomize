FROM alpine:3.13.5 AS base

RUN apk update && \
    apk add \
    curl \
    jq

ENTRYPOINT ["sh", "-o", "pipefail", "-c"]


# Version Checkers
FROM base AS latest-kubectl-version

CMD [ \
    "curl -fs https://storage.googleapis.com/kubernetes-release/release/stable.txt | \
    sed -e 's/\\v\\(.*\\)$/\\1/'" \
]


FROM base AS latest-kustomize-release

WORKDIR /tmp

RUN curl -fs https://api.github.com/repos/kubernetes-sigs/kustomize/releases > .kustomize-latest-release


FROM latest-kustomize-release AS latest-kustomize-version

CMD [ \
    "cat .kustomize-latest-release | \
    jq -r 'first(.[] | select(.name | startswith(\"kustomize/\"))) | .name' | \
    sed -e 's/\\kustomize\\/v\\(.*\\)$/\\1/'" \
]

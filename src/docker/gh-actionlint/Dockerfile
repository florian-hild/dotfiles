FROM golang:alpine

ENV CGO_ENABLED=0 GOOS=linux

RUN apk --no-cache add git
RUN go install github.com/rhysd/actionlint/cmd/actionlint@latest
RUN addgroup --gid 10001 actionlint && \
    adduser --disabled-password --gecos "" --home /work --no-create-home --uid 10000 --ingroup actionlint actionlint && \
    mkdir -p /work && \
    chown -R actionlint:actionlint /work

WORKDIR /work

ENTRYPOINT ["actionlint"]


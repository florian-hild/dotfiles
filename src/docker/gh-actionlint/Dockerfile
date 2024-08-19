FROM golang:alpine

ENV CGO_ENABLED=0 GOOS=linux

RUN apk --no-cache add git
RUN go install github.com/rhysd/actionlint/cmd/actionlint@latest

WORKDIR /work

ENTRYPOINT ["actionlint"]


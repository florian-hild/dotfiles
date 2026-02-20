FROM container-registry.oracle.com/os/oraclelinux:9

ENV LANG=C.UTF-8 \
    TZ='Europe/Berlin'

RUN dnf --nodocs -y upgrade-minimal && \
    dnf --nodocs -y install --setopt=install_weak_deps=False \
        rpm-build rpmdevtools rpmlint \
        tree unzip make git && \
    dnf clean all && \
    mkdir -p /workspace

WORKDIR /workspace

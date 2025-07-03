FROM container-registry.oracle.com/os/oraclelinux:10
RUN <<EOF
  dnf --nodocs -y upgrade-minimal
  dnf --nodocs -y install --setopt=install_weak_deps=False \
    rpm-build \
    rpmdevtools \
    rpmlint \
    unzip \
    tree \
    git \
    make
  dnf clean all
  # Fix: /sbin/ldconfig: Can't open cache file /etc/ld.so.cache
  ldconfig
EOF

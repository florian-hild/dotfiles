FROM container-registry.oracle.com/os/oraclelinux:9-slim

ARG JAVA_VERSION=21

ENV LANG="C.UTF-8" \
    TZ="Europe/Berlin" \
    JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk \
    JAVA_TOOL_OPTIONS="-Duser.timezone=Europe/Berlin -Xint"

# === Install base packages ===
# java-1.8.0 needed to prevent gradle to download adoptium-jdk-8-linux from maven repo
RUN microdnf -y upgrade --nodocs && \
    microdnf -y install --nodocs \
      tree less which vi hostname make git \
      java-${JAVA_VERSION}-openjdk java-${JAVA_VERSION}-openjdk-devel \
      java-1.8.0-openjdk java-1.8.0-openjdk-devel

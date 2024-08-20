FROM perl:stable

ENV DEBIAN_FRONTEND=noninteractive \
    PERL_CPANM_OPT="--notest" \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt update && \
    apt install -y --no-install-recommends build-essential curl git && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN curl -L https://cpanmin.us | perl - App::cpanminus && \
    cpanm --notest Perl::Critic
RUN groupadd -g 10001 runtime && \
    useradd -u 10000 -g runtime runtime && \
    mkdir -p /work && \
    chown -R runtime:runtime /work

WORKDIR /work
USER runtime:runtime

ENTRYPOINT ["perlcritic"]
CMD ["--severity", "3", "."]



FROM bitnami/minideb:buster

ARG GH_RUNNER_VERSION
ARG DOCKER_COMPOSE_VERSION="1.24.1"

ENV RUNNER_NAME=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_TOKEN=""
ENV RUNNER_REPOSITORY_URL=""
ENV RUNNER_LABELS=""
ENV RUNNER_ALLOW_RUNASROOT=true
ENV GITHUB_ACCESS_TOKEN=""
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y \
    apt-transport-https \
    curl \
    ca-certificates \
    zlib1g-dev \
    liblttng-ust0 \
    git \
    supervisor \
    jq \
    ;

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Install Docker-Compose
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

RUN mkdir -p /home/runner ${AGENT_TOOLSDIRECTORY}

WORKDIR /home/runner

RUN GH_RUNNER_VERSION=${GH_RUNNER_VERSION:-$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')} \
    && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R root: /home/runner \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ARG VERSION
ARG BUILD_DATE
ARG SOURCE_COMMIT

LABEL org.opencontainers.image.authors="William Artero"
LABEL org.opencontainers.image.url="https://github.com/wwmoraes/github-runner"
LABEL org.opencontainers.image.documentation="https://github.com/wwmoraes/github-runner"
LABEL org.opencontainers.image.source="https://github.com/wwmoraes/github-runner"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.vendor="William Artero"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.ref.name="wwmoraes/github-runner"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${SOURCE_COMMIT}"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        python3 \
        sqlite3 \
        libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN corepack enable

WORKDIR /workspace

COPY start-backstage.sh /usr/local/bin/start-backstage.sh
RUN chmod +x /usr/local/bin/start-backstage.sh

CMD ["/usr/local/bin/start-backstage.sh"]

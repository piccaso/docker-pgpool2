FROM alpine:3.10 as base

FROM base as download
RUN apk add --no-cache curl wget ca-certificates
RUN update-ca-certificates
RUN wget https://github.com/noqcks/gucci/releases/download/v0.0.4/gucci-v0.0.4-linux-amd64 -O /usr/bin/gucci \
    && chmod +x /usr/bin/gucci

FROM base as final

COPY --from=download /usr/bin/gucci /usr/bin/gucci

RUN apk add --no-cache pgpool \
    && mkdir -p /etc/pgpool2/ /var/run/pgpool/ /etc/pgpool2/

ENV PCP_PORT=9898 \
    PCP_USERNAME=postgres \
    PCP_PASSWORD=1234 \
    PGPOOL_PORT=5432 \
    PGPOOL_BACKENDS=db:5432:10 \
    TRUST_NETWORK=0.0.0.0/0 \
    PG_USERNAME=postgres \
    PG_PASSWORD=1234 \
    NUM_INIT_CHILDREN=32 \
    MAX_POOL=4 \
    CHILD_LIFE_TIME=300 \
    CHILD_MAX_CONNECTIONS=0 \
    CONNECTION_LIFE_TIME=0 \
    CLIENT_IDLE_LIMIT=0

ADD config/pcp.conf.template /usr/share/pgpool2/pcp.conf.template
ADD config/pgpool.conf.template /usr/share/pgpool2/pgpool.conf.template
ADD config/pool_hba.conf.template /usr/share//pgpool2/pool_hba.conf.template
ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 9898
EXPOSE 5432

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]

CMD ["pgpool", "-n", "-f", "/etc/pgpool.conf", "-F", "/etc/pcp.conf", "-a", "/etc/pool_hba.conf"]

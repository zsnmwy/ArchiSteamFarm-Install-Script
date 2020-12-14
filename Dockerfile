FROM justarchi/archisteamfarm:released

RUN echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | tee -a /etc/apt/sources.list.d/caddy-fury.list  && \
    apt update && \
    apt install caddy expect curl -y && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

COPY Caddyfile .
COPY openssl ./openssl
COPY entry.sh .

RUN chmod +x entry.sh

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD [ "./entry.sh" ]
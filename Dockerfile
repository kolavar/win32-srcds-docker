FROM ubuntu:resolute

ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive
ARG DEPOTDOWNLOADER_VERSION=3.4.0
ARG HANGOVER_VERSION=11.16
ARG APP_ID=740
ARG DEPOT_ID=740
ARG MANIFEST=4234207694164018948
ARG APP_ID_GAME=730
ARG DEPOT_ID_GAME=731
ARG MANIFEST_GAME=3388427691642807733

ENV STEAMAPPDIR=/opt/steam \
    HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:99 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=no \
    RUN_FLUXBOX=yes \
    RUN_SRCDS=yes

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) DD_ARCH=x64 ;; \
      arm64) DD_ARCH=arm64 ;; \
      *) echo "unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl unzip; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /tmp/dd "${STEAMAPPDIR}"; \
    curl -fsSL -o /tmp/dd.zip \
      "https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_${DEPOTDOWNLOADER_VERSION}/DepotDownloader-linux-${DD_ARCH}.zip"; \
    unzip /tmp/dd.zip -d /tmp/dd; \
    chmod +x /tmp/dd/DepotDownloader; \
    /tmp/dd/DepotDownloader \
      -app "${APP_ID}" -depot "${DEPOT_ID}" -manifest "${MANIFEST}" \
      -dir "${STEAMAPPDIR}" -os windows; \
    /tmp/dd/DepotDownloader \
      -app "${APP_ID_GAME}" -depot "${DEPOT_ID_GAME}" -manifest "${MANIFEST_GAME}" \
      -dir "${STEAMAPPDIR}"; \
    rm -rf /tmp/dd /tmp/dd.zip

RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        fluxbox net-tools novnc supervisor xauth x11vnc xterm xvfb cabextract; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
      apt-get install -y wine; \
      xvfb-run -a wineboot --init; \
      dpkg --add-architecture i386; \
      apt-get update; \
      apt-get install -y \
          lib32gcc-s1 \
          lib32stdc++6 \
          lib32z1 \
          libtinfo6:i386 \
          libncurses6:i386 \
          libcurl4-gnutls-dev:i386; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
      curl -fsSL -o /tmp/hangover.tar \
        "https://github.com/AndreRH/hangover/releases/download/hangover-${HANGOVER_VERSION}/hangover_${HANGOVER_VERSION}_ubuntu2604_resolute_arm64.tar"; \
      mkdir -p /tmp/hangover; \
      tar -xf /tmp/hangover.tar -C /tmp/hangover; \
      apt-get install -y /tmp/hangover/*.deb; \
      rm -rf /tmp/hangover /tmp/hangover.tar; \
      wineboot --init; \
      dpkg --add-architecture armhf; \
      apt-get update; \
      apt-get install -y \
          libgcc-s1:armhf \
          libstdc++6:armhf \
          zlib1g:armhf \
          libtinfo6:armhf \
          libncurses6:armhf \
          libcurl4-gnutls-dev:armhf; \
    else \
      echo "unsupported TARGETARCH=${TARGETARCH}" >&2; \
      exit 1; \
    fi; \
    rm -rf /var/lib/apt/lists/*

COPY srcds_run.sh ${STEAMAPPDIR}

WORKDIR /app

COPY conf.d conf.d
COPY supervisord.conf .
COPY entrypoint.sh .

EXPOSE 27015/tcp 27015/udp
EXPOSE 8080/tcp

ENTRYPOINT ["/app/entrypoint.sh"]

ARG ALPINE_VERSION=edge
# versions must correspond with APKBUILD
ARG NEATVNC_VERSION="1.0.0-r0"
ARG WAYVNC_VERSION="0.10.0-r1"
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Björn Busse <bj.rn@baerlin.eu>"
LABEL org.opencontainers.image.source=https://github.com/bbusse/swayvnc-build
ARG TARGETARCH
ARG NEATVNC_VERSION

# Tested with: x86_64 / aarch64
ENV _APKBUILD="https://git.alpinelinux.org/aports/plain/community/neatvnc/APKBUILD" \
     PKG_NEATVNC="neatvnc-${NEATVNC_VERSION}.apk" \
     PKG_NEATVNC_DEV="neatvnc-dev-${NEATVNC_VERSION}.apk" \
     USER="build"

# Add build requirements
RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    # Add signing keys
    && apk add -X https://nl.alpinelinux.org/alpine/edge/main -u alpine-keys --allow-untrusted \
    && apk update \
    && apk upgrade \
    && apk add alpine-sdk curl gnutls-dev

# Add build user
RUN addgroup -S $USER && adduser -D $USER -G $USER -G abuild \
    && chown -R $USER /var/cache/distfiles

# Build
USER $USER
WORKDIR /home/$USER
RUN curl -LO $_APKBUILD \
    && abuild-keygen -a -n

USER root
RUN cp /home/$USER/.config/abuild/*.rsa.pub /etc/apk/keys/

USER $USER
RUN abuild checksum \
    && abuild -r \
    && ls .local/share/abuild/home/$(uname -m)/ \
    && cp /home/$USER/.local/share/abuild/home/$(uname -m)/$PKG_NEATVNC_DEV . \
    && cp /home/$USER/.local/share/abuild/home/$(uname -m)/$PKG_NEATVNC .

FROM alpine:${ALPINE_VERSION} AS builder_1
ARG ALPINE_VERSION
ARG NEATVNC_VERSION

ENV _APKBUILD="https://git.alpinelinux.org/aports/plain/community/wayvnc/APKBUILD" \
     PKG_NEATVNC="neatvnc-${NEATVNC_VERSION}.apk" \
     PKG_NEATVNC_DEV="neatvnc-dev-${NEATVNC_VERSION}.apk" \
     USER="build"

# Add build requirements
RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    # Add signing keys
    && apk add -X https://nl.alpinelinux.org/alpine/edge/main -u alpine-keys --allow-untrusted \
    && apk update \
    && apk add alpine-sdk curl

# Add build user
RUN addgroup -S $USER && adduser -D $USER -G $USER -G abuild \
    && chown -R $USER /var/cache/distfiles

# Copy
USER $USER
WORKDIR /home/$USER
COPY --from=0 /etc/apk/keys /etc/apk/keys
COPY --from=0 /home/$USER/$PKG_NEATVNC .
COPY --from=0 /home/$USER/$PKG_NEATVNC_DEV .

USER root
# Install copied dependencies
RUN apk update - allow-untrusted && \
    apk add $PKG_NEATVNC $PKG_NEATVNC_DEV

ARG WAYVNC_VERSION
ENV PKG_WAYVNC="wayvnc-${WAYVNC_VERSION}.apk"

# Build
USER $USER
WORKDIR /home/$USER
RUN curl -LO $_APKBUILD \
    # Remove any local *.patch entries from the source/checksum
    # list, we only fetch the main tarball, not upstream's patches
    && awk '!/\.patch[[:space:]]*$/' APKBUILD > APKBUILD_ \
    && rm APKBUILD \
    && mv APKBUILD_ APKBUILD \
    && abuild-keygen -a -n

USER root
RUN cp /home/$USER/.config/abuild/*.rsa.pub /etc/apk/keys/

USER $USER
RUN abuild checksum \
    && abuild -r \
    && ls .local/share/abuild/home/$(uname -m)/ \
    && cp /home/$USER/.local/share/abuild/home/$(uname -m)/$PKG_WAYVNC .

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

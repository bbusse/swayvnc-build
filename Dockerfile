ARG ALPINE_VERSION=3.12
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Björn Busse <bj.rn@baerlin.eu>"
LABEL org.opencontainers.image.source https://github.com/bbusseR/swayvnc-build

# Tested with: x86_64 / aarch64
ENV _APKBUILD="https://git.alpinelinux.org/aports/plain/community/neatvnc/APKBUILD" \
     ARCH="aarch64" \
     USER="build"

# Add build requirements
RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk update \
    && apk add alpine-sdk gnutls-dev 

# Add build user
RUN addgroup -S $USER && adduser -S $USER -G $USER -G abuild \
    && chown -R $USER /var/cache/distfiles

# Build
USER $USER
WORKDIR /home/$USER
RUN curl -LO $_APKBUILD \
    && abuild-keygen -a -n \
    && abuild checksum \
    && abuild -r

FROM alpine:3.12 as builder_1

ENV _APKBUILD="https://git.alpinelinux.org/aports/plain/community/wayvnc/APKBUILD" \
     PKG_NEATVNC="neatvnc-0.3.1-r0.apk" \
     PKG_NEATVNC_DEV="neatvnc-dev-0.3.1-r0.apk" \
     ARCH="aarch64" \
     USER="build"

# Add build requirements
RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk update \
    && apk add alpine-sdk

# Add build user
RUN addgroup -S $USER && adduser -S $USER -G $USER -G abuild \
    && chown -R $USER /var/cache/distfiles

# Copy
USER $USER
WORKDIR /home/$USER
COPY --from=0 /home/$USER/packages/home/$ARCH/$PKG_NEATVNC .
COPY --from=0 /home/$USER/packages/home/$ARCH/$PKG_NEATVNC_DEV .

USER root
# Install copied dependencies
RUN apk add --allow-untrusted $PKG_NEATVNC $PKG_NEATVNC_DEV

# Build
USER $USER
WORKDIR /home/$USER
RUN curl -LO $_APKBUILD \
    && abuild-keygen -a -n \
    && abuild checksum \
    && abuild -r

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

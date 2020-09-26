FROM alpine:3.12 as builder_0

# Tested with: x86_64 / aarch64
ENV _APKBUILD https://git.alpinelinux.org/aports/plain/community/neatvnc/APKBUILD
ENV ARCH aarch64
ENV USER build

# Add build requirements
RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN apk update
RUN apk add alpine-sdk gnutls-dev

# Add build user
RUN addgroup -S $USER && adduser -S $USER -G $USER -G abuild
RUN chown -R $USER /var/cache/distfiles

# Build
USER $USER
WORKDIR /home/$USER
RUN curl -LO $_APKBUILD
RUN abuild-keygen -a -n
RUN abuild checksum
RUN abuild -r

FROM alpine:3.12 as builder_1

ENV _APKBUILD https://git.alpinelinux.org/aports/plain/community/wayvnc/APKBUILD
ENV PKG_NEATVNC neatvnc-0.3.1-r0.apk
ENV PKG_NEATVNC_DEV neatvnc-dev-0.3.1-r0.apk
ENV ARCH aarch64
ENV USER build

# Add build requirements
RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN apk update
RUN apk add alpine-sdk

# Add build user
RUN addgroup -S $USER && adduser -S $USER -G $USER -G abuild
RUN chown -R $USER /var/cache/distfiles

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
RUN curl -LO $_APKBUILD
RUN abuild-keygen -a -n
RUN abuild checksum
RUN abuild -r

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

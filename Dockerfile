FROM alpine:3.12 as builder

# Tested with: x86_64 / aarch64
ENV _APKBUILD https://git.alpinelinux.org/aports/plain/community/wayvnc/APKBUILD
ENV ARCH aarch64
ENV USER build

# Add build requirements
RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN apk update
RUN apk add alpine-sdk neatvnc

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

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

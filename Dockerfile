FROM alpine:3.12

# Tested with: x86_64 / aarch64
ENV ARCH aarch64
ENV USER build

RUN echo $'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN apk update

# Add build requirements
RUN apk add alpine-sdk

# Add build and application user
RUN addgroup -S $USER && adduser -S $USER -G $USER -G abuild
RUN chown -R $USER /var/cache/distfiles

# Get and build wayvnc
USER $USER
WORKDIR /home/$USER
ADD https://git.alpinelinux.org/aports/plain/community/wayvnc/APKBUILD /home/$USER
RUN abuild-keygen -a -n
RUN abuild checksum
RUN abuild -r

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

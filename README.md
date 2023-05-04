Builds wayvnc for alpine

## Build container
```
$ podman build -t alpine-pkg-build . 
```

## Copy build artifacts
Run the build container and copy artifacts to local machine
```
$ podman run alpine-pkg-build
# To get the container id 
$ podman container list | grep alpine-pkg-build
$ podman cp $container:/home/vnc-user/packages/home/aarch64/wayvnc-0.6.2-r0.apk .
```

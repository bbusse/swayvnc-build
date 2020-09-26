Builds wayvnc for alpine

## Build container
```
$ podman build -t alpine-pkg-build . 
```

## Copy build artefacts
Run the build container and copy artefacts to local machine
```
$ podman run alpine-pkg-build
# To get the container id 
$ podman container list | grep alpine-pkg-build
$ podman cp $container:/home/vnc-user/packages/home/aarch64/wayvnc-0.2.0-r0.apk .
```

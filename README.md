# Build DKMS packages for ixgbe and e100e drivers

Use Docker to help build debianized DKMS drivers

# Build instructions

## General

```sh
# build for precise by default
make build
# build for trusty
make build-trusty
```

All packages built in the docker container will appear in the `output` directory.


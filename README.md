# Build DKMS packages for ixgbe, e100e, and mpt3sas drivers

Use Docker to help build debianized DKMS drivers

# Build instructions

## General

```sh
# build for Trusty by default
make build
# build for precise
make build-precise
```

All packages built in the docker container will appear in the `output` directory.


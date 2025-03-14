# LocksmithUSB

is an **immutable distro**(based on (Fedora bootc)[https://docs.fedoraproject.org/en-US/bootc/]) tough to be put on a **USB drive** and be booted everywhere to provide you some **useful tool** to repair broken systems.

## What is bootc?

Do you know what a container is? Well, a container image doesn't contain a kernel; so `container image` + `kernel` = `bootable container image`.
The obtained bootable container image can be run on a VM or a bare-metal machine, with the advantage of a highly customizable immutable OS built exploiting traditional OCI tools(e.g. podman) and skills.

To make this magic happen, we use [bootc](https://github.com/containers/bootc).

> Transactional, in-place operating system updates using OCI/Docker container images. bootc is the key component in a broader mission of bootable containers.

## Using

If you want to build your personal **LocksmithUSB** I suggest to you forking this repository, so you can adapt it to your needs.

### Build (locally)

If you prefer to build it locally, you can use [buildah](https://buildah.io/) or [podman](https://podman.io/) to do this job.

```bash
buildah build -t locksmithusb --no-hosts --no-hostname
```

Pay attention: bootc relies on image is published on a public OCI registry, so consider forking this repo to easily use GitHub OCI registry to host it.

### Installation

The OCI image can be also used to install itself on a usb drive.

```bash
podman run \
        --rm \
        --privileged \
        --pid=host \
        --security-opt label=type:unconfined_t \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        ghcr.io/robertobochet/locksmithusb:latest \
        bootc install to-disk \
              --generic-image \
              --filesystem ext4 \
              --wipe \
              /dev/${USB_BLOCK_DEVICE}
```

Further information about the `bootc install` can be found [here](https://bootc-dev.github.io/bootc//bootc-install.html).

### Upgrade

All the system changes(e.g., upgrade, rollback) can be performed with the `bootc` command from the booted disto.

```bash
bootc status
```

With the above command, yuo can check the current status of the system.
In particular, you can find the reference to the current booted image (remember it respects the OCI standards) and the previous image(it can be used for a rollback). An output example follows

```text
● Booted image: ghcr.io/robertobochet/locksmithusb:latest
        Digest: sha256:399c9a71da4fb879010617f33cc4511e7fab4373dfde45acd9d3bf0f61759b2f
       Version: 0.1.1 (2025-02-06 17:47:04.319141040 UTC)

  Rollback image: ghcr.io/robertobochet/locksmithusb:latest
          Digest: sha256:c2ba60b8b6c40a422ee13a82c4e572774d675f395979fb3a9da6c756bb6d45bc
         Version: 0.1.0 (2025-02-05 19:18:41.038133299 UTC)
```

#### Upgrade without changing the image reference

You should check the system is able to retrieve the new image with the following command

```bash
bootc upgrade --check
```

If an upgrade is available, it can be performed with the following command

```bash
bootc upgrade [--apply]
```

Pay attention; after the upgrade is completed, the new image will be used at the next reboot.
With the `--apply` option, the system performs a full reboot to switch to new image immediately.

#### Upgrade changing the image reference

If you want to upgrade the system with a new image with a different reference, you should perform a switch operation.

```bash
bootc switch [--apply] ghcr.io/robertobochet/locksmithusb:${IMAGE_TAG}
```

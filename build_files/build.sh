#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

KERNEL=$(skopeo inspect --retry-times 3 docker://ghcr.io/atiusamy/bluefin-stable:latest | jq -r '.Labels["ostree.linux"]')

mv -v /etc/driver_files/* /lib/modules/${KERNEL}
rm -rf /etc/driver_files

# install the kernel headers

# dnf5 -y copr disable ublue-os/staging
#### Example for enabling a System Unit File

depmod ${KERNEL}



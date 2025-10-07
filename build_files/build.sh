#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1


# this installs a package from fedora repos
dnf5 install -y gcc kernel-devel make patch wget kernel-headers tar
# install the kernel headers

# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

depmod ${KERNEL}



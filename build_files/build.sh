#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y gcc kernel-devel make patch wget kernel-headers tar

git clone https://github.com/davidjo/snd_hda_macbookpro.git
cd snd_hda_macbookpro/
#run the following command as root or with sudo
set +e

	# attempt to download linux-x.x.x.tar.xz kernel
wget -c https://cdn.kernel.org/pub/linux/kernel/v$major_version.x/linux-$kernel_version.tar.xz -P $build_dir

if [[ $? -ne 0 ]]; then
	echo "Failed to download linux-$kernel_version.tar.xz"
	echo "Trying to download base kernel version linux-$major_version.$minor_version.tar.xz"
	echo "This may lead to build failures as too old"
	echo "If this is an Ubuntu-based distribution this almost certainly will fail to build"
	echo ""
   	# if first attempt fails, attempt to download linux-x.x.tar.xz kernel
   	kernel_version=$major_version.$minor_version
   	wget -c https://cdn.kernel.org/pub/linux/kernel/v$major_version.x/linux-$kernel_version.tar.xz -P $build_dir

	[[ $? -ne 0 ]] && echo "kernel could not be downloaded...exiting" && exit
fi

set -e

tar --strip-components=3 -xvf $build_dir/linux-$kernel_version.tar.xz --directory=build/ linux-$kernel_version/sound/pci/hda

mv $hda_dir/Makefile $hda_dir/Makefile.orig
cp $patch_dir/Makefile $patch_dir/patch_cirrus_* $hda_dir
pushd $hda_dir > /dev/null

if [ $major_version -gt $current_major ]; then
	iscurrent=2
elif [ $major_version -eq $current_major -a $minor_version -gt $current_minor ]; then
	iscurrent=2
elif [ $major_version -eq $current_major -a $minor_version -eq $current_minor ]; then
	iscurrent=1
else
	iscurrent=-1
fi
patch -b -p2 <../../patch_patch_cs8409.c.diff

if [ $iscurrent -ge 0 ]; then
	patch -b -p2 <../../patch_patch_cs8409.h.diff
else
	patch -b -p2 <../../patches/patch_patch_cs8409.h.main.pre519.diff
fi

cp $patch_dir/Makefile $patch_dir/patch_cirrus_* $hda_dir/

if [ $iscurrent -ge 0 ]; then
	patch -b -p2 <../../patch_patch_cirrus_apple.h.diff
fi

popd > /dev/null

make KERNELRELEASE=$UNAME
make install KERNELRELEASE=$UNAME

echo -e "\ncontents of $update_dir"


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File



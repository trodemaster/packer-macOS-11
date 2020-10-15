.DELETE_ON_ERROR:

all:
	echo >&2 "Must specify target."

# use forked installinstallmacos.py to specify beta seed and 11.0 installer
download_installer:
	python submodules/macadmin-scripts/installinstallmacos.py --seedprogram DeveloperSeed --beta --version 11.0

# Create an iso of the macOS instaler to use with vmware
prereqs:
	sh scripts/buildprereqs.sh

# create user pkgs using pycreateuserpkg
buildpkgs:
	sh scripts/makepkgs.sh

# run packer creating only a base image (full imagre requires xcode downloads)
run_packer:
	packer build -only=base.vmware-iso.macOS_11_base macOS_11.pkr.hcl

clean:
	rm -rf content/*

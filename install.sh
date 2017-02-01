#! /bin/bash
#

if [ -z $1 ]; then
    echo "Installer wrapper for gnu-install-bin. Usage:"
    echo ""
    echo "  ./install.sh TARGETDIR [options]"
    echo ""
    echo "For options try"
    echo ""
    echo "  ./install.sh --help"
fi

ruby=./installer/bin/traveling-ruby-20141215-2.1.5-linux-x86_64/bin/ruby
patchelf=./installer/bin/patchelf
guix_relocate=./installer/bin/guix-relocate
gnu_install_bin=./installer/bin/gnu-install-bin

# Change into package dir
pkgdir=$(dirname $0)
cd $pkgdir

# Check we are not in the source dir
if [ -e VERSION ]; then
  echo "ERROR: This script should not be run in source dir of the installer"
  exit 1
fi

# Run the Ruby installer
$ruby -I ./installer/lib/installer/ $gnu_install_bin --guix-relocate=$guix_relocate --patchelf=$patchelf $*
echo "Done"
exit $?

#! /bin/bash
#
# Installer wrapper for gnu-install-bin
#

ruby=./bin/traveling-ruby-20141215-2.1.5-linux-x86_64/bin/ruby
patchelf=./bin/patchelf

# Chainge into package dir
pkgdir=$(dirname $0)
cd $pkgdir

# Check we are not in the source dir
if [ -e VERSION ]; then
  echo "This script should not be run in source dir"
  exit 1
fi

# Run the Ruby installer
echo RUN: $ruby ./bin/gnu-install-bin $*
$ruby -I ./lib/installer/ ./bin/gnu-install-bin --patchelf=$patchelf $*
echo "Done"
exit $?

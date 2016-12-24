# gnu-install-bin

Linux one-click software installation without root!

## Introduction

Here we are aiming for one-click installs on Linux without root
privileges using the amazing GNU Guix software packaging
system.

Software deployment without needing root access and without the
complexity and conflicts other software packaging systems are infamous
for.

gnu-install-bin is a generic software installer for relocatable GNU
Guix binary packages. It takes an unpacked directory of packages as
copied from the /gnu/store and copies them to a new location (the
current working directory by default). In the process it translates
all contained paths to the new location(s).

Notice: this project is work in progress.

## Usage

When a tree gets unpacked it contains the installer. Say a file was
downloaded named guix-hello-2.10-x86\_64.tar.gz it unpacks in a
directory guix-hello-2.10-x86\_64 which contains the executable
command gnu-install-bin. Run the installer with

    ./guix-hello-2.10-x86_64/install.sh [-v] [-d] [target-dir]

If no target-dir is set the current directory is used for
installation.

## Requirements

Minimal Linux system containing common basic utilities bash, dd, grep and strings.

Static versions of ruby and patchelf are included.

Root access is *not* required!

## Improvements

The current code is written in Ruby and runs on the bundled
[travelling Ruby](https://github.com/phusion/traveling-ruby/blob/master/TUTORIAL-1.md)
which has been linked against static libraries. In then future we may
switch to another implementation.

## How does the installer work?

This installer starts from an unpacked directory structure that gets
mirrored in the target dir. The origin directory can contain *any*
type of file. It is up to the package creator to add and strip files.

When a file gets copied it gets checked for its contents and patched with
[patchelf](https://github.com/NixOS/patchelf) and the dd system tool.

patchelf was statically compiled from source with

    g++ -Wall -static -std=c++11 -D_FILE_OFFSET_BITS=64 -g -O2 -DPACKAGE_NAME=\"patchelf\" -DPACKAGE_TARNAME=\"patchelf\" -DPACKAGE_VERSION=\"0.10\" -DPACKAGE_STRING=\"patchelf\ 0.10\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"patchelf\" -DVERSION=\"0.10\" -DPAGESIZE=4096 -I. -D_FILE_OFFSET_BITS=64 patchelf.cc -o patchelf

For more detail check the source code.

## Security

gnu-install-bin is meant to be non-opiniated. That means it is up to
the package provider who can install modified Guix package contents
and additional directories and files. The installer can install
packages that have not been signed and have been downloaded from
untrusted sources. Signing and adding keys are optional features which
may be added by the package provider.

## AUTHOR

Copyright 2016-2017 Pjotr Prins <pjotr.guix@thebird.nl>

## LICENSE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## HOMEPAGE

Not yet available.

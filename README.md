# gnu-install-bin

Linux one-click software installation without root!

## Introduction

Here we are aiming for that on Linux using the amazing GNU Guix
software packaging system. Without needing root access and without the
conflicts other software packaging systems are infamous for.

gnu-install-bin is (a prototype of) a generic software installer for
relocatable GNU Guix binary packages. It takes an unpacked directory
of packages as copied from the /gnu/store and copies them to a new
location (the current working directory by default). In the process it
translates all contained paths to the new location(s).

## Usage

When a tree gets unpacked it contains the installer. Say a file was
downloaded named guix-hello-2.10-x86\_64.tar.gz it unpacks in a
directory guix-hello-2.10-x86\_64 which contains the executable
command gnu-install-bin. Run the installer with

    ./guix-hello-2.10-x86_64/gnu-install-bin [target-dir]

## Requirements

1. Minimal Linux system containing
   * Linux kernel
2. [patchelf](https://github.com/NixOS/patchelf) on the path (this requirement will be removed in future versions)
3. A recent Ruby interpreter on the path (this requirement will be removed in future versions)

Root access is *not* required!

## Improvements

To remove the Ruby requirement it is possible to bundle travelling
[Ruby](https://github.com/phusion/traveling-ruby/blob/master/TUTORIAL-1.md).

Likewise, patchelf can be made generic to install.

## How does the installer work?

### Directory structure gets copied to target

The installer starts from an unpacked directory structure that gets
mirrored in the target dir. The origin directory can contain *any*
type of file. It is up to the package creator to add and strip files.

When a file gets copied it gets checked for its contents:

### Binary files

### Script files

### Other files

## Security

gnu-install-bin is non-opiniated. That means it is up to the package
provider who can install modified Guix package contents and additional
directories and files. The installer can install packages that have
not been signed and have been downloaded from untrusted
sources. Signing and adding keys are optional features which may be
added by the package provider.

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

Not yet.

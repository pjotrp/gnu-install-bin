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
copied from the /gnu/store (this can be created by a closure or guix
'environment') and copies them to a new location (the current working
directory by default). In the process it translates all contained
paths to the new location(s).

Notice: this project is work in progress.

## Usage

When a tree gets unpacked it contains the installer. Say a file was
downloaded named guix-hello-2.10-x86\_64.tar.gz it unpacks in a
directory guix-hello-2.10-x86\_64 which contains the executable
command install.sh. Run the installer with

    ./guix-hello-2.10-x86_64/install.sh [-v] [-d] target-dir

## Example

Sambamba is a package defined in [guix-bioinformatics](https://github.com/genenetwork/guix-bioinformatics/blob/master/gn/packages/bioinformatics.scm#L923). By the SHA values you can check the git versions that
have been used. It was built using a recent ldc compiler 1.1.0-beta6. It is linked against

    ldd guix-sambamba-0.6.5-x86_84/gnu/store/bnb76qdkn0fk99l5ph7xbzy51nw188p4-sambamba-0.6.5-c6f52cc/bin/sambamba
        linux-vdso.so.1 (0x00007fffe95ae000)
        librt.so.1 => /gnu/store/m9vxvhdj691bq1f85lpflvnhcvrdilih-glibc-2.23/lib/librt.so.1 (0x00007f74557db000)
        libpthread.so.0 => /gnu/store/m9vxvhdj691bq1f85lpflvnhcvrdilih-glibc-2.23/lib/libpthread.so.0 (0x00007f74555be000)
        libm.so.6 => /gnu/store/m9vxvhdj691bq1f85lpflvnhcvrdilih-glibc-2.23/lib/libm.so.6 (0x00007f74552b8000)
        libgcc_s.so.1 => /gnu/store/if3ww39qs6267acvl2l9a0wc78wi960h-gcc-4.9.3-lib/lib/libgcc_s.so.1 (0x00007f74550a2000)
        libc.so.6 => /gnu/store/m9vxvhdj691bq1f85lpflvnhcvrdilih-glibc-2.23/lib/libc.so.6 (0x00007f7454d00000)
        /gnu/store/m9vxvhdj691bq1f85lpflvnhcvrdilih-glibc-2.23/lib/ld-linux-x86-64.so.2 (0x00007f74559e3000)

Which references need to be relocated by the installer.

Fetch and unpack

    wget http://biogems.info/contrib/genenetwork/guix-sambamba-0.6.5-x86_84.tgz
    tar tvzf guix-sambamba-0.6.5-x86_84.tgz

Run the installer (you can use -v and -d options for verbosity)

    ./guix-sambamba-0.6.5-x86_84/install.sh ~/opt/sambamba-0.6.5

Ignore any warnings (harmless here). Run the sambamba tool with

    ~/opt/sambamba-0.6.5/gnu/sambamba-0.6.5-c6f52cc/bin/sambamba

## How does the installer work?

This installer starts from an unpacked directory structure that gets
mirrored in the target dir. The origin directory can contain *any*
type of file. It is up to the package creator to add and strip files.

When a file gets copied it gets checked for its contents and patched with
[patchelf](https://github.com/NixOS/patchelf) and the dd system tool or,
altenatively, with the new guix-relocator binary.

All installer related files are in the ./installer/ directory.

## Strategies

There are three strategies for patching binary files.

### Fixed strategy

The first and, arguably, most safe strategy is *fixed* where all GNU
path references are patched with the exact same length. Example:

Found @512:     /gnu/store/qv7bk62c22ms9i11dhfl71hnivyc82k2-glibc-2.22
Replace with    /gnu/tmp/hello/glibc-2.22-qv7bk62c22ms9i11dhfl71hnivyc

You can see we swap the hash position and start 'eating' the path from
the end all the way down.  The upside is that this should work across
almost all files, unless the path is stored in unicode or scrambled in
some way. The downside of the fixed strategy is that a prefix can not
grow beyond the size of the one in the store. Also every store path
may look a bit different between installs.

### Fit strategy

The second strategy is *fit* which replaces guix paths with an
alternative. Example

Found @512:     /gnu/store/qv7bk62c22ms9i11dhfl71hnivyc82k2-glibc-2.22
Replace with    /gnu/tmp/hello/glibc-2.22-qv7bk62c

This works for elf files and all interpreted script files, such as
from bash and Ruby. It will not work for a number of compiled files,
such as JAVA byte code and Python pyc, unless we add support in the
future. If the installer encounters such a file it will bail out.

### Expand strategy

The third strategy is essentially the same as the *fit* strategy, but
it will ignore the items it can not expand, say in compiled Python
.pyc files where the stored path is not zero terminated. It will emit
a warning instead.


### What strategy to choose

The person who writes the installer is responsible for choosing the
strategy - the strategy is set in the install.sh script. For many
packages the *fit* or *expand* strategy may work fine. When they do
not work use the *fixed* strategy. The GNU store path is reasonably
long, so for most cased fixed size patching will work fine.

## Requirements

Minimal Linux system containing common basic utilities bash, dd, grep and strings.

Static versions of ruby, guix-relocate and patchelf are included.

Root access is *not* required!

## Known issues

1. Internationalization (i8n, locales) is not yet working
2. If the prefix is too long the installer will stop in the *fit* and
   *fixed* strategies and *expand* may lead to unpredicted
   behaviour. Safest to keep the prefix within range.
3. Rewriting some binary file non-elf formats may not (yet) work for
   *fit* and *expand* strategies.

Currently, for the *fit* and *expand* strategies in binary files, the
patcher works back stripping characters until it finds a valid file
path. This may not always be a good idea. We'll have to take it case
by case.

## Security

gnu-install-bin is meant to be non-opiniated. That means it is up to
the package provider who can install modified Guix package contents
and additional directories and files. The installer can install
packages that have not been signed and have been downloaded from
untrusted sources. Signing and adding keys are optional features which
may be added by the package provider.

## Included binaries

### patchelf

patchelf is statically compiled from source with

    g++ -Wall -static -std=c++11 -D_FILE_OFFSET_BITS=64 -g -O2 -DPACKAGE_NAME=\"patchelf\" -DPACKAGE_TARNAME=\"patchelf\" -DPACKAGE_VERSION=\"0.10\" -DPACKAGE_STRING=\"patchelf\ 0.10\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"patchelf\" -DVERSION=\"0.10\" -DPAGESIZE=4096 -I. -D_FILE_OFFSET_BITS=64 patchelf.cc -o patchelf

### guix-relocate

Guix relocate is used for the *fixed* strategy and is written in D by
the author and is also statically compiled.

### Travelling Ruby

The current code is written in Ruby and runs on the bundled
[travelling Ruby](https://github.com/phusion/traveling-ruby/blob/master/TUTORIAL-1.md)
which has been linked against static libraries. In then future we may
switch to another implementation.

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

# gnu-install-bin

## Introduction

Remember those heady days on Windows where you just could run a setup
program and it would just work? Here we are aiming for that on Linux
using the amazing GNU Guix software packaging system. And without the
conflicts other software packaging systems are famous for.

gnu-install-bin is a prototype of a generic software installer for
relocatable GNU Guix binary packages. It takes an unpacked directory
of packages as copied from the /gnu/store and copies them to a new
location (the current working directory by default). In the process
it translates all contained paths to the new location(s).

This prototype is written in Ruby, just because I write prototypes
fastest in the language. Once solid, this code will be ported to a
low-level language.

## Usage

When a tree gets unpacked it contains the installer. Say a file was
downloaded named guix-hello-2.10-x86\_64.tar.gz it unpacks in a
directory guix-hello-2.10-x86\_64 which contains the executable
command gnu-install-bin. Run it

    ./guix-hello-2.10-x86_64/gnu-install-bin [target-dir]

## Security

gnu-install-bin is non-opiniated. That means it can install modified
Guix package contents and additional directories and files. It can
also install packages that have not been signed and have been
downloaded from untrusted sources. Signing and adding keys are
optional features which may be added by the party providing the
package.

#!/bin/sh

workspace="$PWD/build/_workspace"

root="$PWD"

GOBIN="$PWD/build/bin"


pofiddir="$workspace/src/github.com/pofid-dao"


go get -u github.com/goware/modvendor

#
rm -rf "$workspace"
#
#libsuperzk.so
#
modvendor -copy="**/*.c **/*.h **/*.proto **/*.so **/*.dyld **/*.A **/*.B0 **/*.B1 **/*.H **/*.L **/*.bin" -v
#
##
mkdir -p "$pofiddir/go-pofid"
##
cp -R ` find .   \( -path "./build" -o -path "./.git" -o -path "./contract" -o -path "./.idea" -o -path "./images" -o -path "./go.mod" \) -prune -o -type d -depth 1 -print ` "$pofiddir/go-pofid"


# Set up the environment to use the workspace.

GOPATH="$workspace"
export GOPATH

# Run the command inside the workspace.
cd "$pofiddir/go-pofid"

export DYLD_LIBRARY_PATH="$pofiddir/go-pofid/vendor/github.com/sero-cash/go-czero-import/czero/lib_LINUX_AMD64_V3"
#
#export DYLD_LIBRARY_PATH
#
#export LD_LIBRARY_PATH="$pofiddir/go-pofid/czero/lib"

#mkdir -p "$pofiddir/go-pofid/vendor/github.com/sero-cash/go-czero-import/czero/lib/"

#ls "$pofiddir/go-pofid/vendor/github.com/sero-cash/go-czero-import/czero/lib_LINUX_AMD64_V3"

#
cp -r "$pofiddir/go-pofid/vendor/github.com/sero-cash/go-czero-import/czero/lib_LINUX_AMD64_V3/"* "$pofiddir/go-pofid/vendor/github.com/sero-cash/go-czero-import/czero/lib/"
#
echo $DYLD_LIBRARY_PATH

echo $PATH


#
xgo  --targets="$1" -v  --dest=$GOBIN ./pofid
#
cd "$root"

#
rm -rf "$root/vendor"
#
rm -rf "$workspace"


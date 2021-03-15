#!/bin/bash

function abort() {
    echo ""
    echo "Aborting installation..."
    sleep 2
    exit 1
}

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN"
esac

pushd /tmp

if [ "$machine" == "Linux" ]; then
    if [ `getconf LONG_BIT` = "64" ]; then
        export MAKOZ=mako.linux-x64.tar.gz
        echo "Downloading 64 bit version"
        curl -o xlua http://makoserver.net/download/xlua/linux-64/xlua || abort
    else
        export MAKOZ=mako.linux-x32.tar.gz
        echo "Downloading 32 bit version"
        curl -o xlua http://makoserver.net/download/xlua/linux-32/xlua || abort
    fi 
    curl http://makoserver.net/download/$MAKOZ --output mako.gz || abort
    tar xzf mako.gz || abort
    rm mako.gz
elif  [ "$machine" == "Mac" ]; then
    curl -o xlua http://makoserver.net/download/xlua/mac/xlua || abort
    curl -o mako.mac.x64.zip http://makoserver.net/download/mako.mac.x64.zip
    unzip -o mako.mac.x64.zip
    rm mako.mac.x64.zip
else
   echo "Sorry, script not designed for this machine"
   abort
fi 

popd

mv /tmp/mako .  || abort
mv /tmp/mako.zip .  || abort
mv /tmp/xlua .  || abort
chmod +x xlua

git clone https://github.com/ColorlibHQ/AdminLTE.git || abort
git clone https://github.com/RealTimeLogic/LSP-Examples || abort
cp -r LSP-Examples/Dashboard/source/. AdminLTE.new || abort
cp -r AdminLTE/dist AdminLTE.new/ || abort
cp -r AdminLTE/plugins AdminLTE.new/ || abort
./xlua LSP-Examples/Dashboard/build.lua AdminLTE || abort

echo "Starting Mako Server: navigate to http://localhost:port-number"

./mako -l::AdminLTE.new


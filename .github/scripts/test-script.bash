# check perl version
perl --version

cd /tmp
wget $LABONE_VERSION
tar -xf LabOne*
mkdir -p ~/local/lib ~/local/include
cp LabOne*/API/C/include/ziAPI.h ~/local/include
cp LabOne*/API/C/lib/libziAPI-linux64.so ~/local/lib
export LD_LIBRARY_PATH=$HOME/local/lib
export LIBRARY_PATH=$LD_LIBRARY_PATH
export CPATH=$HOME/local/include
printenv LD_LIBRARY_PATH

cd $GITHUB_WORKSPACE
perl Makefile.PL
make
/tmp/LabOne*/DataServer/ziDataServer &
prove -bv t xt

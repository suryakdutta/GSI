#!/bin/sh

set -ex

cd ..
pwd=$(pwd)

target=${1:-cray}
dir_root=${2:-$pwd}
clean=${3:-"YES"}

if [ $target = wcoss ]; then
    . /usrx/local/Modules/3.2.10/init/sh
    conf_target=nco
elif [ $target = cray -o $target = wcoss_c ]; then
    . $MODULESHOME/init/sh
    conf_target=nco
elif [ $target = dell -o $target = wcoss_d ]; then
    . $MODULESHOME/init/sh
    conf_target=nco
elif [ $target = theia ]; then
    . /apps/lmod/lmod/init/sh
    conf_target=theia
elif [ $target = s4 ]; then
    . /opt/apps/lmod/3.1.9/init/sh
    conf_target=s4
else
    echo "unknown target = $target"
    exit 9
fi

dir_modules=$dir_root/modulefiles
if [ ! -d $dir_modules ]; then
    echo "modulefiles does not exist in $dir_modules"
    exit 10
fi
[ -d $dir_root/exec ] || mkdir -p $dir_root/exec

module purge
if [ $target = wcoss -o $target = cray ]; then
    module load $dir_modules/modulefile.gdas_enkf.$target
elif [ $target = dell -o $target = wcoss_d ] ; then
    module use $dir_modules/
    module load modulefile.gdas_enkf.$target
else
    source $dir_modules/modulefile.gdas_enkf.$target
fi
module list

cd $dir_root/src/enkf
./configure clean
./configure $conf_target
make -f Makefile clean
make -f Makefile -j 8
cp -p global_enkf $dir_root/exec

if [ $clean = YES ]; then
    make -f Makefile clean
    ./configure clean
    # Now clean the GSI directory
    cd ..
    make -f Makefile clean
    ./configure clean
fi

exit 0

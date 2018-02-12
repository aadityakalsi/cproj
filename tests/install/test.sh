#!/usr/bin/env sh
dirnm=`dirname $0`
filnm=`basename $0`
exec=`cd $dirnm && pwd`/$filnm
currdir=`dirname $exec`
parent=`dirname $currdir`
root=`dirname $parent`

set -e
set -x

if [ -z "$GENERATOR" ]; then
    gen_arg=
else
    gen_arg="-G'$GENERATOR'"
fi

if [ "$CMAKE_BUILD_TYPE" = "" ]; then
    bldType=RelWithDebInfo
else
    bldType="$CMAKE_BUILD_TYPE"
fi

cmd="cmake -H. -B$currdir/_build $gen_arg -DCMAKE_INSTALL_PREFIX=$root/_install -DTESTS_DIR=$root/tests -DCMAKE_BUILD_TYPE=$bldType"
sh -c "$cmd"
env VERBOSE=1 cmake --build $currdir/_build --target tests_run --config "$bldType" > $currdir/testLog.txt
# rm -fr $currdir/_build

echo '----------------------------------------------------------'
echo '# TEST LOG                                               #'
echo '----------------------------------------------------------'
cat $currdir/testLog.txt
echo '----------------------------------------------------------'

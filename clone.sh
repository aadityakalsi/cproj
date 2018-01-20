#!/usr/bin/env sh

if [ "$#" -ne 1 ]; then
    printf "Usage:\n\t$0 <dir>\n"
    exit 1;
fi

set -e

dirnm=`dirname $0`
filnm=`basename $0`
exec=`cd $dirnm && pwd`/$filnm
srcDir=`dirname $exec`

projDir=`mkdir -p $1 && cd $1 && pwd`

mkdir -p $projDir

projName=`basename $projDir`
projNameUpper=`echo $projName | tr [a-z] [A-Z]`

# handle CMakeLists.txt
echo 'Creating CMakeLists.txt...'
cat $srcDir/CMakeLists.txt | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/CMakeLists.txt

# handle export header
echo 'Creating the exports header...'
mkdir -p $projDir/export/$projName
cat $srcDir/export/proj/exports.h | sed "s/<PKG>/$projNameUpper/g" > $projDir/export/$projName/exports.h

# handle cmake/projConfig.cmake.in
mkdir -p $projDir/cmake
cmakeConfig="$projDir/cmake/$projName"Config.cmake.in
cat $srcDir/cmake/projConfig.cmake.in | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $cmakeConfig
cat $srcDir/cmake/deps.cmake | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/cmake/deps.cmake
echo 'Creating 3p dep handling and installation config for project...'
cp $srcDir/cmake/HunterGate.cmake $projDir/cmake

# handle build.sh, clean.sh, tests-install.sh
echo 'Creating build.sh, clean.sh, tests-install.sh scripts...'
cp $srcDir/build.sh $srcDir/clean.sh $srcDir/tests-install.sh $projDir

# copy stub.c
mkdir -p $projDir/src/$projName
echo 'Creating stub.c file...'
cat $srcDir/src/proj/stub.c | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/src/$projName/stub.c

# copy tests
mkdir -p $projDir/tests/install
echo 'Creating tests...'
cp -rf $srcDir/tests $projDir/
cat $srcDir/tests/exports.c | sed "s/<PKG>/$projName/g" | sed "s/<PKGUPPER>/$projNameUpper/g" > $projDir/tests/exports.c

# handle tests.cmake and install/CMakeLists.txt
echo 'Creating tests CMakeLists.txt...'
cat $srcDir/tests.cmake | sed "s/<PKG>/$projName/g" > $projDir/tests.cmake
cat $srcDir/tests/install/CMakeLists.txt | sed "s/<PKG>/$projName/g" > $projDir/tests/install/CMakeLists.txt

# copy LICENSE
echo 'Copying LICENSE...'
cat $srcDir/LICENSE | sed "s/<YEAR>/`date +%Y`/g" > $projDir/LICENSE

# copy travis / appveyor files
echo 'Copying TravisCI and AppVeyor files...'
cp $srcDir/.travis.yml $projDir
cat $srcDir/appveyor.yml | sed "s/<PKG>/$projName/g" > $projDir/appveyor.yml

# copy createhdr/createsrc scripts
echo 'Copying createhdr.sh, createsrc.sh scripts...'
cp $srcDir/createhdr.sh $srcDir/createsrc.sh $srcDir/createtest.sh $projDir/

# copy ChangeLog.txt
echo 'Creating ChangeLog.txt file...'
cp $srcDir/ChangeLog.txt $projDir/

# create a .gitignore
echo 'Creating a .gitignore file...'
sh -c "cat > $projDir/.gitignore" <<EOF
# gitignore for $projName
.hunter/
_build/
_install/
tests/install/_source
tests/install/_build
tests/install/testLog.txt
EOF

# set up clang-format
echo 'Creating a clang-format file...'
sh -c "cat > $projDir/.clang-format" <<EOF
BasedOnStyle: Mozilla
IndentWidth: 4
Language: Cpp
PointerAlignment: Right
ColumnLimit: 80
UseTab: Never
BreakBeforeBraces: Custom
BraceWrapping:
  AfterFunction: true
  AfterStruct: true
  AfterEnum: true
  AfterUnion: true
IndentPPDirectives: AfterHash
AlignEscapedNewlines: Left
AlignOperands: true
EOF

echo 'Creating format-code.sh script...'
sh -c "cat > $projDir/format-code.sh" <<EOF
#!/usr/bin/env bash
srcdir=\$(readlink -f \$(dirname "\$0"))
cd "\$srcdir"
clang-format -i export/$projName/*.h* src/$projName/*.c* src/$projName/*.h* tests/*.c*
EOF
chmod u+x $projDir/format-code.sh

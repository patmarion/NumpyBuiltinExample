#!/bin/bash
#
# See the documentation in README.md. When you're ready, just execute ./run.sh
# and the output will be placed in a new directory named 'build'.
#

# these tools will be used
gcc=`which gcc`
make=`which make`
patch=`which patch`
head=`which head`
tar=`which tar`
makeParallel=-j8

# get the location of this script
scriptDir=$(cd $(dirname $0) && pwd)

# create the output directory
outDir=$scriptDir/build
mkdir -p $outDir

# define some useful variables
filesDir=$scriptDir/files
pyversion=2.7
pythonPackageName=Python-2.7.3
numpyPackageName=numpy-1.6.2
pythonSourceDir=$outDir/$pythonPackageName
numpySourceDir=$outDir/$numpyPackageName
installDir=$outDir/install
python=$installDir/bin/python
freezeOutputDir=$outDir/freezeOutput

# remove python related environment variables
unset PYTHONHOME
unset PYTHONPATH
unset PYTHONSTARTUP


############################
# define the script routines

extractAndBuildPython()
{
  cd $outDir
  $tar -zxf $filesDir/$pythonPackageName.tgz
  cd $pythonSourceDir

  # patch python import
  $patch -p0 < $filesDir/patch-python-import.diff

  # setup builtin modules
  cp $filesDir/Setup.local ./Modules/

  ./configure install --disable-shared --prefix $installDir || exit
  $make $makeParallel || exit
  $make install || exit
}


extractAndBuildNumpy()
{
  cd $outDir
  $tar -zxf $filesDir/$numpyPackageName.tar.gz
  cd $numpyPackageName
  $python ./setup.py install --prefix $installDir || exit
}


runFreezeTool()
{
  targetScript=$filesDir/freezeInputScript.py
  freezeScript=$pythonSourceDir/Tools/freeze/freeze.py
  ignores="-X codecs -X copy -X distutils -X encodings -X locale -X macpath -X ntpath -X os2emxpath -X popen2 -X pydoc  -X readline -X _warnings"

  export PYTHONHOME=$installDir
  export PYTHONPATH=$installDir/lib/python$pyversion/site-packages

  $python -S $freezeScript -o $freezeOutputDir -p $pythonSourceDir $ignores $targetScript || exit

  unset PYTHONHOME
  unset PYTHONPATH

  # convert frozen.c to frozen.h by removing the "int main()" function at the end
  cd $freezeOutputDir
  numberOfLines=$(cat frozen.c | wc -l)
  numberOfLinesToKeep=$(expr $numberOfLines - 9)
  $head -n $numberOfLinesToKeep frozen.c > frozen.h
}

buildHelloNumpy()
{
  cd $outDir
  cp -r $filesDir/helloNumpy ./
  cd helloNumpy

  pythonInclude=$installDir/include/python$pyversion
  pythonLibrary=$installDir/lib/libpython$pyversion.a
  numpyBuildDir=$numpySourceDir/build

  # glob numpy .o files and frozen .c source files
  numpyObjects=$(find $numpyBuildDir -name \*.o)
  frozenSources=$(find $freezeOutputDir -name M_\*.c)

  # osx and linux take slightly different linking flags
  if [ "$(uname)" == "Darwin" ]; then
    linkFlags=""
    requiredBlasLibrary="-framework Accelerate"
  else
    linkFlags="-Xlinker -export-dynamic"
    requiredBlasLibrary=""
  fi

  requiredLibs="-lpthread -lm -ldl -lutil"

  # compile hello.c
  $gcc $linkFlags -o hello hello.c -I$pythonInclude $pythonLibrary $requiredLibs

  # compile hello.c with HELLO_FROZEN defined
  # this build includes the numpy object files and frozen source files
  $gcc $linkFlags -DHELLO_FROZEN -o helloFrozen hello.c -I$pythonInclude -I$freezeOutputDir \
        $frozenSources \
        $numpyObjects \
        $pythonLibrary \
        $requiredBlasLibrary \
        $requiredLibs

}

##########################
# call the script routines

set -x
extractAndBuildPython
extractAndBuildNumpy
runFreezeTool
buildHelloNumpy


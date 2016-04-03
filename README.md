Numpy Builtin Example
=====================

This project demonstrates how to build a basic program that embeds
Python and NumPy.  The compiled binary uses static linking and frozen
modules in order to be fully standalone.  NumPy and the Python
standard library are embedded into the binary so that no .py or .so
extension modules are required at runtime.  The program can run
without reading anything from the filesystem.  This style of embedding
is useful in environments where it might be preferable to avoid
filesystem access, such as supercomputers and mobile devices.

The run.sh script will compile python and numpy, and then build two
programs called hello and helloFrozen.

Python is configured so that most of the standard C extension modules
are "builtin", meaning that they are compiled into the libpython
archive library.  At runtime, a statement like "import math" will not
dynamically load math.so- all of the code that would normally be in
the math.so shared library is actually in the libpython.a archive.

Numpy is compiled with default settings.

The hello program is linked against libpython.a.  It behaves similarly
to a standard python interpreter program.  Invoked without arguments
it will start an interactive prompt, if given a filename argument it
will exec the file.  The list of builtin modules can be displayed by
printing out the value of sys.builtin_module_names.

The helloFrozen program is compiled along with "frozen" source files
and numpy object files.  This means the a statement like "import os"
will not read os.py from the filesystem- the contents of os.py are
compiled into the helloFrozen program via the "frozen" source files.
Also, when importing numpy, none of the numpy C extension modules will
be dynamically loaded- all the numpy code is compiled into helloFrozen
via the numpy object files.  The helloFrozen program can function
without reading any of the .py and .so files that belong to numpy and
the python standard library.

To test the programs, try running them with test.py:

    $ build/helloNumpy/hello files/helloNumpy/test.py
    $ build/helloNumpy/helloFrozen files/helloNumpy/test.py

The run.sh build script has been tested on Ubuntu 12.04 and 14.04, and OSX 10.8
(Mountain Lion).  When you're ready, just execute ./run.sh and the
output will be placed in a new directory named 'build'.

Blas and Lapack
---------------

If you don't have blas installed, then numpy won't attempt to build
the dotblas module.  In that case, you should edit the file
`files/helloNumpy/numpy_builtin.h` and comment out the lines
mentioning dotblas.

If blas and lapack are installed on the system, then numpy will be
configured with blas and lapack support.  That adds a required link
dependency on those libraries.  Edit run.sh and you'll find a variable
named requiredBlasLibrary.  For macosx, it is set to a default value,
but for linux it is empty.  You have to fill that in for your system.
On my Ubuntu 14 system, this is the value that worked for me:

    requiredBlasLibrary="/usr/lib/liblapack.a /usr/lib/libblas.a /usr/lib/gcc/x86_64-linux-gnu/4.8/libgfortran.a"

For more information about linkage, see:

http://stackoverflow.com/questions/9000164/how-to-check-blas-lapack-linkage-in-numpy-scipy

You can also check the dynamic linkage on the compiled numpy modules
that are placed in the build output directory, for example:


    $ ldd ./build/numpy-1.6.2/build/lib.linux-x86_64-2.7/numpy/core/_dotblas.so
        linux-vdso.so.1 =>  (0x00007ffe451f9000)
        libcblas.so.3 => /usr/lib/libcblas.so.3 (0x00007ff10b542000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007ff10b324000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007ff10af5f000)
        libatlas.so.3 => /usr/lib/libatlas.so.3 (0x00007ff10a9cc000)
        libgfortran.so.3 => /usr/lib/x86_64-linux-gnu/libgfortran.so.3 (0x00007ff10a6b2000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007ff10a49c000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007ff10a196000)
        /lib64/ld-linux-x86-64.so.2 (0x00007ff10b969000)
        libquadmath.so.0 => /usr/lib/x86_64-linux-gnu/libquadmath.so.0 (0x00007ff109f5a000)

    $ ldd ./build/numpy-1.6.2/build/lib.linux-x86_64-2.7/numpy/linalg/lapack_lite.so
        linux-vdso.so.1 =>  (0x00007ffee099f000)
        liblapack.so.3 => /usr/lib/liblapack.so.3 (0x00007f609193f000)
        libf77blas.so.3 => /usr/lib/libf77blas.so.3 (0x00007f609171f000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f609135a000)
        libblas.so.3 => /usr/lib/libblas.so.3 (0x00007f6090d8e000)
        libgfortran.so.3 => /usr/lib/x86_64-linux-gnu/libgfortran.so.3 (0x00007f6090a74000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f609076e000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f6090558000)
        libcblas.so.3 => /usr/lib/libcblas.so.3 (0x00007f6090337000)
        libatlas.so.3 => /usr/lib/libatlas.so.3 (0x00007f608fda4000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f608fb86000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f60922e3000)
        libquadmath.so.0 => /usr/lib/x86_64-linux-gnu/libquadmath.so.0 (0x00007f608f94a000)

Other libraries you might need to add are /usr/lib/libcblas.a and
/usr/lib/libatlas.a, and note that the order that .a library files are
listed does matter.

Slither
-------

Another project you may be interested in is Slither. Whereas this
project, NumpyBuiltinExample, attempts to provide a minimal example,
Slither is an automated tool to help you build frozen programs with
numpy:

    https://github.com/bfroehle/slither

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

The run.sh build script has been tested on Ubuntu 12.04 and OSX 10.8
(Mountain Lion).  When you're ready, just execute ./run.sh and the
output will be placed in a new directory named 'build'.  

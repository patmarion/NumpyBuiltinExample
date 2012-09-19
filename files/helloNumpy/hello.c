#include <Python.h>

#ifdef HELLO_FROZEN
#include "numpy_builtin.h"
#include "frozen.h"
#endif

#include <stdio.h>

int main(int argc, char **argv)
{

  FILE* inFile = 0;
  if (argc > 1) {
      inFile = fopen(argv[1], "r");
      if (!inFile) {
        printf("Failed to open file: %s\n", argv[1]);
        return 1;
      }
  }

#ifdef HELLO_FROZEN
  add_numpy_builtin();
  PyImport_FrozenModules = _PyImport_FrozenModules;
  Py_FrozenFlag = 1;
  Py_NoSiteFlag = 1;
#endif

  Py_SetProgramName(argv[0]);
  Py_Initialize();

  int retCode;

  if (inFile) {
    retCode = PyRun_SimpleFile(inFile, argv[1]);
    fclose(inFile);
  } 
  else {
    retCode = Py_Main(argc, argv);
  }

  Py_Finalize();

  return retCode;
}


#include <Python.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void initmultiarray();
extern void initmultiarray_tests();
extern void initscalarmath();
extern void initumath();
extern void initumath_tests();
extern void init_sort();
extern void init_dotblas();
extern void initfftpack_lite();
extern void init_compiled_base();
extern void initlapack_lite();
extern void init_capi();
extern void initmtrand();

void add_numpy_builtin()
{
  PyImport_AppendInittab("numpy.core.multiarray", initmultiarray);
  PyImport_AppendInittab("numpy.core.multiarray_tests", initmultiarray_tests);
  PyImport_AppendInittab("numpy.core.scalarmath", initscalarmath);
  PyImport_AppendInittab("numpy.core.umath", initumath);
  PyImport_AppendInittab("numpy.core.umath_tests", initumath_tests);
  PyImport_AppendInittab("numpy.core._dotblas", init_dotblas);
  PyImport_AppendInittab("numpy.core._sort", init_sort);
  PyImport_AppendInittab("numpy.fft.fftpack_lite", initfftpack_lite);
  PyImport_AppendInittab("numpy.lib._compiled_base", init_compiled_base);
  PyImport_AppendInittab("numpy.linalg.lapack_lite", initlapack_lite);
  PyImport_AppendInittab("numpy.numarray._capi", init_capi);
  PyImport_AppendInittab("numpy.random.mtrand", initmtrand);
}

#ifdef __cplusplus
}
#endif

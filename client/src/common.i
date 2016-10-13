%typemap(out) rfbBool {
    $result = PyBool_FromLong($1);
}

%typemap(in) rfbBool {
    if (PyBool_Check($input)) {
        if ($input == (PyObject *) Py_True)
            $1 = TRUE;
        else
            $1 = FALSE;
    } else {
        PyErr_SetString(PyExc_TypeError, "Expected boolean");
        return NULL;
    }
}

%typemap(in) (int* argc, char *argv[]) {
    if (PyList_Check($input)) {
        int i;
        $1 = (int *) malloc(sizeof(int));
        *$1 = PyList_Size($input);
        $2 = (char **) malloc((*$1+1) * sizeof(char *));
        for (i=0; i<*$1; i++) {
            PyObject *o = PyList_GetItem($input, i);
            if (PyUnicode_Check(o)) {
                $2[i] = PyUnicode_AsUTF8(PyList_GetItem($input, i));
            }
            else {
                PyErr_SetString(PyExc_TypeError, "Argument list must contain strings.");
                free($2);
                return NULL;
            }
        }
        $2[i] = 0;
    } else {
        PyErr_SetString(PyExc_TypeError, "Expected a list.");
        return NULL;
    }
}

%typemap(freearg) (int* argc, char *argv[]) {
    free((int *) $1);
    free((char *) $2);
}

%apply (int* argc, char *argv[]) { (int* argc, char **argv) };

%typemap(in) (char *text) {
    Py_INCREF($input);
    if (PyUnicode_Check($input)) {
        PyObject *bytes = PyUnicode_AsASCIIString($input);
        if (bytes == NULL) {
            PyErr_SetString(PyExc_TypeError, "Can't convert to ASCII.");
            return NULL;
        } else {
            $1 = PyBytes_AsString(bytes);
        }
    } else if (PyBytes_Check($input)) {
        $1 = PyBytes_AsString($input);
    } else {
        PyErr_SetString(PyExc_TypeError, "Expected string or bytes.");
        return NULL;
    }
    
}

%typemap(in) (char *str, int len) {
    Py_INCREF($input);
    if (PyUnicode_Check($input)) {
        PyObject *bytes = PyUnicode_AsASCIIString($input);
        if (bytes == NULL) {
            PyErr_SetString(PyExc_TypeError, "Can't convert to ASCII.");
            return NULL;
        } else {
            $1 = PyBytes_AsString(bytes);
            $2 = (int) PyBytes_Size(bytes);
        }
    } else if (PyBytes_Check($input)) {
        $1 = PyBytes_AsString($input);
        $2 = (int) PyBytes_Size($input);
    } else {
        PyErr_SetString(PyExc_TypeError, "Expected string or bytes.");
        return NULL;
    }
    
}


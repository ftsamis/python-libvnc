%nodefault _rfbClientWrapper;
%rename("RFBClient") _rfbClient;

%{
// A structure to hold metadata required for the Python interface,
// such as the various Python callback functions.
// FIXME: This is probably a temporary design.
typedef struct _rfbClientPyData {
    rfbBool initialized;
    struct _rfbClient *client;
    PyObject *got_framebuffer_update;
    PyObject *handle_cursor_pos;
    PyObject *finished_framebuffer_update;
} rfbClientPyData;

static void GotFrameBufferUpdateProxyCallback(struct _rfbClient *client, int x, int y, int w, int h);
static rfbBool HandleCursorPosProxyCallback(struct _rfbClient *client, int x, int y);
static void FinishedFrameBufferUpdateProxyCallback(struct _rfbClient *client);
static int clients_count = 0;
static rfbClientPyData *client_wrappers[512] = {0};

rfbClientPyData *get_pydata_for_client(rfbClient *client) {
    int i;
    for (i=0; i<clients_count; i++) {
        rfbClientPyData *pydata = client_wrappers[i];
        if (pydata->client == client) {
            return pydata;
        }
    }
}

static void GotFrameBufferUpdateProxyCallback(rfbClient *client, int x, int y, int w, int h) {
    rfbClientPyData *pydata = get_pydata_for_client(client);

    PyObject *python_cb = pydata->got_framebuffer_update;
    if (python_cb != NULL) {
        PyObject *args = Py_BuildValue("iiii", x, y, w, h);
        PyObject_CallObject(python_cb, args);
        Py_DECREF(args);
    }
}

static rfbBool HandleCursorPosProxyCallback(rfbClient *client, int x, int y) {
    rfbClientPyData *pydata = get_pydata_for_client(client);
    PyObject *python_cb = pydata->handle_cursor_pos;
    if (python_cb != NULL) {
        PyObject *args = Py_BuildValue("ii", x, y);
        PyObject_CallObject(python_cb, args);
        Py_DECREF(args);
    }
    return TRUE;
}

static void FinishedFrameBufferUpdateProxyCallback(rfbClient *client) {
    rfbClientPyData *pydata = get_pydata_for_client(client);

    PyObject *python_cb = pydata->finished_framebuffer_update;
    if (python_cb != NULL) {
        PyObject_CallObject(python_cb, NULL);
    }
}

const rfbBool _rfbClient_initialized_get(rfbClient *client) {
    rfbClientPyData *pydata = get_pydata_for_client(client);
    return pydata->initialized;
}
    
%}



typedef struct _rfbClient {
    uint8_t *frameBuffer;
    int width;
    int height;
    int major;
    int minor;
    int sock;
    char *desktopName;
    
    int KeyboardLedStateEnabled;
	int CurrentKeyboardLedState;

	int canHandleNewFBSize;

    struct {
    int x;
    int y;
    int w;
    int h;
    } updateRect;

    rfbPixelFormat format;

} rfbClient;

%extend _rfbClient {
    const rfbBool initialized;
    
    _rfbClient(int bitsPerSample, int samplesPerPixel, int bytesPerPixel) {
        rfbClient *c = rfbGetClient(bitsPerSample, samplesPerPixel, bytesPerPixel);
        rfbClientPyData *pydata = malloc(sizeof(rfbClientPyData));
        pydata->client = c;
        pydata->initialized = FALSE;
        client_wrappers[clients_count++] = pydata;

        return c;
    }
    
    ~_rfbClient() {
        // libvncclient calls rfbClientCleanup() when rfbInitClient fails
        // so we need to take care not to free the same memory twice.
        rfbClientPyData *pydata = get_pydata_for_client($self);
        if (pydata->initialized) {
            rfbClientCleanup($self);
        }
        free(pydata);
    }
    
    %exception init_client {
        $action
        if (!result) {
            PyErr_SetString(PyExc_RuntimeError, "Could not initialize client");
            return NULL;
        }
    }
    
    rfbBool init_client(int *argc, char **argv) {
        rfbBool success = rfbInitClient($self, argc, argv);
        rfbClientPyData *pydata = get_pydata_for_client($self);
        pydata->initialized = success;
        return success;
    }
    
    rfbBool send_pointer_event(int x, int y, int button_mask) {
        return SendPointerEvent($self, x, y, button_mask);
    }
    
    rfbBool send_key_event(int key, rfbBool down) {
        return SendKeyEvent($self, key, down);
    }
    
    rfbBool send_client_cut_text(char *str, int len) {
        return SendClientCutText($self, str, len);
    }
    
    int wait_for_message(int usecs) {
        return WaitForMessage($self, usecs);
    }
    
	rfbBool handle_server_message() {
	    return HandleRFBServerMessage($self);
    }
    
    rfbBool text_chat_send(char *text) {
        return TextChatSend($self, text);
    }
    
    rfbBool text_chat_open() {
        return TextChatOpen($self);
    }
    
    rfbBool text_chat_close() {
        return TextChatClose($self);
    }
    
    PyObject *set_got_framebuffer_update_callback(PyObject *cb) {
        if (!PyCallable_Check(cb)) {
            PyErr_SetString(PyExc_TypeError, "Need a callable object!");
            return NULL;
        }
        Py_XINCREF(cb);
        rfbClientPyData *pydata = get_pydata_for_client($self);
        pydata->got_framebuffer_update = cb;
        $self->GotFrameBufferUpdate = GotFrameBufferUpdateProxyCallback;
        Py_RETURN_NONE;
    }
    
    PyObject *set_handle_cursor_pos_callback(PyObject *cb) {
        if (!PyCallable_Check(cb)) {
            PyErr_SetString(PyExc_TypeError, "Need a callable object!");
            return NULL;
        }
        Py_XINCREF(cb);
        rfbClientPyData *pydata = get_pydata_for_client($self);
        pydata->handle_cursor_pos = cb;
        $self->HandleCursorPos = HandleCursorPosProxyCallback;
        Py_RETURN_NONE;
    }
    
    PyObject *set_finished_framebuffer_update_callback(PyObject *cb) {
        if (!PyCallable_Check(cb)) {
            PyErr_SetString(PyExc_TypeError, "Need a callable object!");
            return NULL;
        }
        Py_XINCREF(cb);
        rfbClientPyData *pydata = get_pydata_for_client($self);
        pydata->finished_framebuffer_update = cb;
        $self->FinishedFrameBufferUpdate = FinishedFrameBufferUpdateProxyCallback;
        Py_RETURN_NONE;
    }

    // FIXME: Temporary design. Copying the framebuffer to a Python bytes object
    // is not what we want.
    PyObject *get_framebuffer() {
        rfbPixelFormat *pf=&$self->format;
	    int bpp = pf->bitsPerPixel/8;
        int size = $self->width * $self->height * bpp;
        return PyBytes_FromStringAndSize($self->frameBuffer, size);
    }
}



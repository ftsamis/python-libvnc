%module __init__
%include <typemaps.i>

%{
#define SWIG_FILE_WITH_INIT
#include <rfb/rfbclient.h>
%}

%pythoncode %{
from libvncclient.rfbclient import *
%}

%include "common.i"

// Use a global rule for renaming to undercase instead of 
// renaming every identifier separately
// e.g. FindFreeTcpPort -> find_free_tcp_port
%rename("%(undercase)s") "";


int FindFreeTcpPort(void);
int ListenAtTcpPort(int port);


%include "rfbproto.i"


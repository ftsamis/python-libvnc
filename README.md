# python-libvnc
Development of Python 3 bindings for libvncserver/libvncclient.
Currently this is only in a proof-of-concept phase for the libvncclient.

# Build dependencies
python3.4-dev
swig3.0
libvncserver-dev

# Run dependencies
python3.4
libvncclient1

# Build instructions
Create a build directory:
```mkdir build```

Use SWIG to generate the C wrapping code along with the top-level python module
```swig3.0 -python -outdir build/ -o build/libvncclient_wrap.c src/libvncclient.i```

Compile the C wrapping code as position independent code
```gcc -O2 -fPIC -c build/libvncclient_wrap.c -I/usr/include/python3.4 -I/usr/include/rfb  -o build/libvncclient_wrap.o```

Link the compiled object to the libvncclient library and create the final shared object
```gcc -shared build/libvncclient_wrap.o -o build/_libvncclient.so -lvncclient```


# Run example
First open a x11vnc server on localhost for our client to connect to and then:

```python
$ python3
Python 3.4.3+ (default, Oct 14 2015, 16:03:50) 
[GCC 5.2.1 20151010] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import libvncclient
>>> client = libvncclient.RFBClient(8,3,4)
>>> client.init_client([])
14/10/2016 01:50:21 ConnectClientToTcpAddr6: getaddrinfo (No address associated with hostname)
14/10/2016 01:50:21 VNC server supports protocol version 3.8 (viewer 3.8)
14/10/2016 01:50:21 We have 1 security types to read
14/10/2016 01:50:21 0) Received security type 1
14/10/2016 01:50:21 Selecting security type 1 (0/1 in the list)
14/10/2016 01:50:21 Selected Security Scheme 1
14/10/2016 01:50:21 No authentication needed
14/10/2016 01:50:21 VNC authentication succeeded
14/10/2016 01:50:21 Desktop name "hades:0"
14/10/2016 01:50:21 Connected to VNC server, using protocol version 3.8
14/10/2016 01:50:21 VNC server default format:
14/10/2016 01:50:21   32 bits per pixel.
14/10/2016 01:50:21   Least significant byte first in each pixel.
14/10/2016 01:50:21   TRUE colour: max red 255 green 255 blue 255, shift red 16 green 8 blue 0
True
>>> client.wait_for_message(50)
1
>>> client.handle_server_message()
True
>>> client.wait_for_message(50)
1
>>> client.handle_server_message()
14/10/2016 01:51:38 client2server supported messages (bit flags)
14/10/2016 01:51:38 00: 00ff 0081 0000 0000 - 0000 0000 0000 0000
14/10/2016 01:51:38 08: 0000 0000 0000 0000 - 0000 0000 0000 0000
14/10/2016 01:51:38 10: 0000 0000 0000 0000 - 0000 0000 0000 0000
14/10/2016 01:51:38 18: 0000 0000 0000 0000 - 0000 0000 0000 0004
14/10/2016 01:51:38 server2client supported messages (bit flags)
14/10/2016 01:51:38 00: 001f 0080 0000 0000 - 0000 0000 0000 0000
14/10/2016 01:51:38 08: 0000 0000 0000 0000 - 0000 0000 0000 0000
14/10/2016 01:51:38 10: 0000 0000 0000 0000 - 0000 0000 0000 0000
14/10/2016 01:51:38 18: 0000 0000 0000 0000 - 0000 0000 0000 0004
14/10/2016 01:51:38 Connected to Server "unknown (LibVNCServer 0.9.10)"
True
>>> client.wait_for_message(50)
1
>>> client.handle_server_message()
True
>>> fb = client.get_framebuffer()
>>> len(fb)
22118400
```

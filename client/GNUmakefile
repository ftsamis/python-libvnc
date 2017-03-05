ifndef PYTHON
    PYTHON=python3
endif

all: generate

generate: setup.py
	$(PYTHON) setup.py build_ext

install: generate
	$(PYTHON) setup.py install

userinstall: generate
	$(PYTHON) setup.py install --user

clean:
	-rm -rf build

veryclean: clean
	-rm -f libvncclient/keysym_wrap.c
	-rm -f libvncclient/__init___wrap.c
	-rm -f libvncclient/keysym.py
	-rm -f libvncclient/__init__.py
	-rm -f libvncclient/rfbclient_wrap.c
	-rm -f libvncclient/rfbclient.py


ifndef PYTHON
    PYTHON=python3
endif

all: generate

generate: setup.py
	$(PYTHON) setup.py build_ext

clean:
	-rm -rf build

veryclean: clean
	-rm -f libvncclient/keysym_wrap.c
	-rm -f libvncclient/libvncclient_wrap.c
	-rm -f libvncclient/keysym.py
	-rm -f libvncclient/libvncclient.py


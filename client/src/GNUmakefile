ifndef PYTHON
    PYTHON=python3
endif

all: generate

generate: setup.py
	$(PYTHON) setup.py build_ext

clean:
	-rm -rf build

veryclean: clean
	-rm -f keysym_wrap.c
	-rm -f libvncclient_wrap.c
	-rm -f keysym.py
	-rm -f libvncclient.py


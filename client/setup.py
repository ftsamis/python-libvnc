#!/usr/bin/env python3
#-*- coding: utf-8 -*-
import os
import re
import subprocess
import distutils.command.build_ext
from distutils.version import LooseVersion
from distutils.spawn import find_executable
from distutils.core import setup, Extension

SWIG_MIN_VERSION    = "3.0" 

class Build_Ext_find_swig3(distutils.command.build_ext.build_ext):
    """ Doc:
    https://pythonhosted.org/bob.extension/_modules/distutils/command/build_ext.html
    https://github.com/vishnubob/wub/blob/master/setup.py
    """

    def find_swig(self):

        if os.name != "posix":
            # Call parent function
            return super(Build_Ext_find_swig3, self).find_swig()
        else:
            return self.get_swig_executable()

    def get_swig_executable(self):
        # Source https://github.com/FEniCS/ffc/blob/master/setup.py
        "Get SWIG executable"

        # Find SWIG executable
        swig_executable = None
        for executable in ["swig3.0", "swig"]:
            swig_executable = find_executable(executable)
            if swig_executable is not None:
                # Check that SWIG version is ok
                output = subprocess.check_output(
                            [swig_executable, "-version"]).decode('utf-8')
                swig_version = re.findall(r"SWIG Version ([0-9.]+)", output)[0]
                if LooseVersion(swig_version) >= LooseVersion(SWIG_MIN_VERSION):
                    break
                swig_executable = None
        if swig_executable is None:
            raise OSError("Unable to find SWIG version %s or higher." % SWIG_MIN_VERSION)
        print("Found SWIG: %s (version %s)" % (swig_executable, swig_version))
        return swig_executable



libvncclient_module = Extension('___init__',
                               sources=['libvncclient/__init__.i'],
                               libraries=['vncclient'],
                               )

rfbclient_module = Extension('_rfbclient',
                           sources=['libvncclient/rfbclient.i'],
                           libraries=['vncclient'],
                           )

keysym_module = Extension('_keysym',
                           sources=['libvncclient/keysym.i'],
                           libraries=['vncclient'],
                           )

setup (name = 'libvncclient',
       version = '0.1',
       author      = "Fotis Tsamis",
       description = """Python bindings for libvncclient""",
       ext_package = "libvncclient",
       ext_modules = [libvncclient_module, rfbclient_module, keysym_module],
       packages = ["libvncclient"],
       cmdclass={
        "build_ext": Build_Ext_find_swig3
       }
       )


#!/usr/bin/env python

from distutils.core import setup
try:
   import sys
   sys.version_info.major
except AttributeError:
   # On old Python versions sys.version_info is a tuple.
   print("Installed version of Python is too old, please update to 2.7")
   sys.exit(1)

setup(
    name = 'njt',
    version = '0.1.0',
    scripts = [
        'scripts/njt'
    ]
)

#!/usr/bin/env python
""" setup.py: a :module:`setuptools`-based setup module for myproj

Run `pip install -e .` to install the local "myproj" package.
"""

from setuptools import find_packages, setup

packages = find_packages(include=["myproj", "myproj.*"])

setup(packages=packages)

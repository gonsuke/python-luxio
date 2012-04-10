from distutils.core import setup
from Cython.Distutils import build_ext
from Cython.Distutils.extension import Extension

classifiers = """
Development Status :: 1 - Beta
Intended Audience :: Developers
Operating System :: OS Independent
Programming Language :: Python :: 2
Topic :: Software Development :: Libraries
Topic :: Database
"""

with open('README.rst') as f:
    long_description = f.read()

setup(
    name='python-luxio',
    version='0.0.3',
    license='New BSD',
    description='Python extension for Lux IO',
    author='Takashi Matsuno',
    author_email='g0n5uk3@gmail.com',
    url='https://github.com/gonsuke/python-luxio',
    long_description=long_description,
    packages = ['luxio'],
    ext_modules=[
        Extension(
            "luxio._luxio",
            ["luxio/_luxio.pyx", "luxio/_luxio.pxd"],
            language="c++",
            libraries=['luxio']
        )
    ],
    cmdclass={'build_ext': build_ext},
)

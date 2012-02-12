from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

classifiers = """
Development Status :: 1 - Beta
Intended Audience :: Developers
Operating System :: OS Independent
Programming Language :: Python
Topic :: Software Development :: Libraries
"""

setup(
    name='python-luxio',
    version='0.0.1',
    description='Python extension for Lux IO',
    author='Takashi Matsuno',
    author_email='g0n5uk3@gmail.com',
    long_description='''Python extension for Lux IO.''',
    ext_modules=[
        Extension(
            "luxio",
            ["luxio.pyx"],
            language="c++",
            libraries=['luxio']
        )
    ],
    cmdclass={'build_ext': build_ext},
)

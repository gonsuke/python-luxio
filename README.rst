===========================
Python extension for Lux IO
===========================

INSTALL
---------
install `Lux IO`__ and  Cython_.

.. __: http://luxio.sourceforge.net/
.. _Cython: http://cython.org/

then 

    $ python setup.py install

HOW TO USE
-----------

::

>>> io = luxio.LuxIO('./test')
>>> io.put('key', 'value')
>>> print io.get('key')
>>> io.delete('key')

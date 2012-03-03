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

  >>> import luxio
  >>> io = luxio.LuxIO('test')
  >>> io.put('key', 'value')
  True
  >>> io.get('key')
  value
  >>> io.delete('key')
  True

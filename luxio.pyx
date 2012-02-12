from cpython cimport *
from libc.stdlib cimport *
from libc.string cimport *
from libc.stdint cimport *
from libcpp cimport *
from libcpp.string cimport string

from _luxio cimport *

cdef extern from "Python.h":
    ctypedef char* const_char_ptr "const char*"
    ctypedef char* const_void_ptr "const void*"
    ctypedef struct PyObject
    cdef int PyObject_AsReadBuffer(object o, const_void_ptr* buff, Py_ssize_t* buf_len) except -1
    cdef int PyObject_AsWriteBuffer(object o, void** buff, Py_ssize_t* buf_len) except -1
    cdef object PyBuffer_FromMemory(void *ptr, Py_ssize_t size)

INDEX_NONCLUSTER = NONCLUSTER
INDEX_CLUSTER = CLUSTER

DB_FILE_RDONLY = DB_RDONLY
DB_FILE_RDWR = DB_RDWR
DB_FILE_CREAT = DB_CREAT
DB_FILE_TRUNC = DB_TRUNC

INSERT_OVERWRITE = OVERWRITE
INSERT_NOOVERWRITE = NOOVERWRITE
INSERT_APPEND = APPEND

cdef class LuxIO:
    cdef Btree *bt
    cdef db_index_t index_type

    def __cinit__(self, object db_file_name, db_flags_t db_flag=DB_CREAT, index_type=NONCLUSTER):
        cdef char* _dbname
        cdef Py_ssize_t _dbnamelen
        PyObject_AsReadBuffer(db_file_name, <const_void_ptr*>&_dbname, &_dbnamelen)

        self.index_type = index_type
        self.bt = new Btree(index_type)

        if not self.bt:
            raise MemoryError()

        cdef string dbname
        dbname.assign(_dbname, _dbnamelen)
        self.bt.open(dbname, db_flag)

    def __dealloc__(self):
        self.bt.close()
        del self.bt

    def put(self, object key, object value, insert_mode=OVERWRITE):
        if insert_mode == APPEND and self.index_type != NONCLUSTER:
            raise ValueError()

        cdef char* keybuf
        cdef Py_ssize_t keylen
        PyObject_AsReadBuffer(key, <const_void_ptr*>&keybuf, &keylen)

        cdef char* valbuf
        cdef Py_ssize_t vallen
        PyObject_AsReadBuffer(value, <const_void_ptr*>&valbuf, &vallen)

        return self.bt.put(keybuf, keylen, valbuf, vallen, insert_mode)

    def get(self, object key):
        cdef char* keybuf
        cdef Py_ssize_t keylen
        PyObject_AsReadBuffer(key, <const_void_ptr*>&keybuf, &keylen)
        cdef data_t* value = self.bt.get(keybuf, keylen)

        if value == NULL: return None

        cdef void* valbuf = <void*>value.data
        return PyBuffer_FromMemory(valbuf, <Py_ssize_t>value.size)

    def delete(self, object key):
        cdef char* keybuf
        cdef Py_ssize_t keylen
        PyObject_AsReadBuffer(key, <const_void_ptr*>&keybuf, &keylen)
        return self.bt.del_(keybuf, keylen)

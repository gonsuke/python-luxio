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
    cdef object PyString_FromStringAndSize(const_char_ptr, Py_ssize_t len)

INDEX_NONCLUSTER = NONCLUSTER
INDEX_CLUSTER = CLUSTER

DB_FILE_RDONLY = DB_RDONLY
DB_FILE_RDWR = DB_RDWR
DB_FILE_CREAT = DB_CREAT
DB_FILE_TRUNC = DB_TRUNC

INSERT_OVERWRITE = OVERWRITE
INSERT_NOOVERWRITE = NOOVERWRITE
INSERT_APPEND = APPEND

STORE_PADDED = Padded
STORE_LINKED = Linked

cdef class LuxIO:
    cdef Btree *bt
    cdef db_index_t index_type
    cdef db_flags_t db_flag

    def __cinit__(self, object db_file_name, db_flags_t db_flag=DB_CREAT, index_type=NONCLUSTER, store_mode=Padded):
        cdef char* _dbname
        cdef Py_ssize_t _dbnamelen
        PyObject_AsReadBuffer(db_file_name, <const_void_ptr*>&_dbname, &_dbnamelen)

        self.db_flag = db_flag
        self.index_type = index_type
        self.bt = new Btree(index_type)

        if not self.bt:
            raise MemoryError()

        if index_type == NONCLUSTER:
            self.bt.set_noncluster_params(store_mode, PO2, 0, 0)

        cdef string dbname
        dbname.assign(_dbname, _dbnamelen)
        self.bt.open(dbname, db_flag)

    def __dealloc__(self):
        self.bt.close()
        del self.bt

    # def close(self):
    #     return self.bt.close()

    def enable_bulk_loading(self):
        self.bt.set_bulk_loading(True)

    def disable_bulk_loading(self):
        self.bt.set_bulk_loading(False)

    def append(self, object key, object value):
        return self.put(key, value, APPEND)

    def put(self, object key, object value, insert_mode=OVERWRITE):
        if self.db_flag == DB_RDONLY:
            raise RuntimeError("DB opened in read-only mode.")

        if insert_mode == APPEND and self.index_type != NONCLUSTER:
            raise RuntimeError("APPEND operation not permitted in CLUSTER mode.")

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

        return PyString_FromStringAndSize(<const_char_ptr>value.data, <Py_ssize_t>value.size)

    def delete(self, object key):
        if self.db_flag == DB_RDONLY:
            raise RuntimeError("DB opened in read-only mode.")

        cdef char* keybuf
        cdef Py_ssize_t keylen
        PyObject_AsReadBuffer(key, <const_void_ptr*>&keybuf, &keylen)
        return self.bt.del_(keybuf, keylen)

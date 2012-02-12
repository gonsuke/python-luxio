from libcpp cimport *
from libcpp.string cimport string

from libc.stdint cimport *

cdef extern from "del.h": pass

cdef extern from "luxio/types.h" namespace "Lux::IO":
    ctypedef int db_flags_t
    cdef db_flags_t DB_RDONLY = 0x0000
    cdef db_flags_t DB_RDWR = 0x0002
    cdef db_flags_t DB_CREAT = 0x0200
    cdef db_flags_t DB_TRUNC = 0x0400

cdef extern from "luxio/dbm.h" namespace "Lux::IO":
    ctypedef enum db_index_t:
        NONCLUSTER = 0
        CLUSTER = 1

    ctypedef enum insert_mode_t:
        OVERWRITE = 0
        NOOVERWRITE = 1
        APPEND = 2

    # cdef enum insert_mode_t:
    #     OVERWRITE, NOOVERWRITE, APPEND

    ctypedef struct data_t:
        void *data
        unsigned int size
        unsigned int user_alloc_size

cdef extern from "luxio/btree.h" namespace "Lux::IO":
    cdef cppclass Btree:
        Btree(db_index_t index_type)
        int open(string db_name, int oflags)
        int close()
        bool put(void*, uint32_t, void*, uint32_t, insert_mode_t)
        data_t *get(void*, uint32_t)
        bool del_(void*, uint32_t)


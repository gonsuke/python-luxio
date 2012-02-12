#!/usr/bin/env python
import luxio
from nose.tools import *

def test_luxio_noncluster_simple():
    io = luxio.LuxIO('./test', db_flag=luxio.DB_FILE_CREAT, index_type=luxio.INDEX_NONCLUSTER)
    assert io.put('0001', '0001', luxio.INSERT_OVERWRITE) == True
    assert io.get('0001') == u'0001'
    assert io.delete('0001') == True
    assert io.get('0001') == None

def test_luxio_noncluster_append():
    io = luxio.LuxIO('./test', db_flag=luxio.DB_FILE_CREAT, index_type=luxio.INDEX_NONCLUSTER)
    assert io.put('0001', '0001', luxio.INSERT_OVERWRITE) == True
    assert io.get('0001') == u'0001'
    assert io.put('0001', '0001', luxio.INSERT_APPEND) == True
    assert io.get('0001') == u'00010001'
    assert io.delete('0001') == True
    assert io.get('0001') == None

@raises(ValueError)
def test_luxio_cluster_append():
    io = luxio.LuxIO('./test', db_flag=luxio.DB_FILE_CREAT, index_type=luxio.INDEX_CLUSTER)
    assert io.put('0001', '0001', luxio.INSERT_APPEND) == True

@nottest
def test_luxio_many_insert():
    io = luxio.LuxIO('./test', db_flag=luxio.DB_FILE_CREAT, index_type=luxio.INDEX_NONCLUSTER)    
    for i in range(1000000):
        yield many_insert, io, i

def many_insert(io, i):
    assert io.put('%08d' % i, '%08d' % i) == True

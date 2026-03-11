.section .text
.global _start

_start:

# TEST 2: add 0x00000000, 0x00000000, 0x00000000
test_2:
    li   x1,  0x00000000
    li   x2,  0x00000000
    add  x3,  x1, x2
    li   x29, 0x00000000
    li   x30, 2
    bne  x3,  x29, fail

# TEST 3: add 0x00000002, 0x00000001, 0x00000001
test_3:
    li   x1,  0x00000001
    li   x2,  0x00000001
    add  x3,  x1, x2
    li   x29, 0x00000002
    li   x30, 3
    bne  x3,  x29, fail

# TEST 4: add 0x0000000a, 0x00000003, 0x00000007
test_4:
    li   x1,  0x00000003
    li   x2,  0x00000007
    add  x3,  x1, x2
    li   x29, 0x0000000a
    li   x30, 4
    bne  x3,  x29, fail

# TEST 5: add 0xffff8000, 0x00000000, 0xffff8000
test_5:
    li   x1,  0x00000000
    li   x2,  0xffff8000
    add  x3,  x1, x2
    li   x29, 0xffff8000
    li   x30, 5
    bne  x3,  x29, fail

# TEST 6: add 0x80000000, 0x80000000, 0x00000000
test_6:
    li   x1,  0x80000000
    li   x2,  0x00000000
    add  x3,  x1, x2
    li   x29, 0x80000000
    li   x30, 6
    bne  x3,  x29, fail

# TEST 7: add 0x7fff8000, 0x80000000, 0xffff8000
test_7:
    li   x1,  0x80000000
    li   x2,  0xffff8000
    add  x3,  x1, x2
    li   x29, 0x7fff8000
    li   x30, 7
    bne  x3,  x29, fail

# TEST 8: add 0x00007fff, 0x00000000, 0x00007fff
test_8:
    li   x1,  0x00000000
    li   x2,  0x00007fff
    add  x3,  x1, x2
    li   x29, 0x00007fff
    li   x30, 8
    bne  x3,  x29, fail

# TEST 9: add 0x7fffffff, 0x7fffffff, 0x00000000
test_9:
    li   x1,  0x7fffffff
    li   x2,  0x00000000
    add  x3,  x1, x2
    li   x29, 0x7fffffff
    li   x30, 9
    bne  x3,  x29, fail

# TEST 10: add 0x80007ffe, 0x7fffffff, 0x00007fff
test_10:
    li   x1,  0x7fffffff
    li   x2,  0x00007fff
    add  x3,  x1, x2
    li   x29, 0x80007ffe
    li   x30, 10
    bne  x3,  x29, fail

# TEST 11: add 0x80007fff, 0x80000000, 0x00007fff
test_11:
    li   x1,  0x80000000
    li   x2,  0x00007fff
    add  x3,  x1, x2
    li   x29, 0x80007fff
    li   x30, 11
    bne  x3,  x29, fail

# TEST 12: add 0x7fff7fff, 0x7fffffff, 0xffff8000
test_12:
    li   x1,  0x7fffffff
    li   x2,  0xffff8000
    add  x3,  x1, x2
    li   x29, 0x7fff7fff
    li   x30, 12
    bne  x3,  x29, fail

# TEST 13: add 0xffffffff, 0x00000000, 0xffffffff
test_13:
    li   x1,  0x00000000
    li   x2,  0xffffffff
    add  x3,  x1, x2
    li   x29, 0xffffffff
    li   x30, 13
    bne  x3,  x29, fail

# TEST 14: add 0x00000000, 0xffffffff, 0x00000001
test_14:
    li   x1,  0xffffffff
    li   x2,  0x00000001
    add  x3,  x1, x2
    li   x29, 0x00000000
    li   x30, 14
    bne  x3,  x29, fail

# TEST 15: add 0xfffffffe, 0xffffffff, 0xffffffff
test_15:
    li   x1,  0xffffffff
    li   x2,  0xffffffff
    add  x3,  x1, x2
    li   x29, 0xfffffffe
    li   x30, 15
    bne  x3,  x29, fail

# TEST 16: add 0x80000000, 0x00000001, 0x7fffffff
test_16:
    li   x1,  0x00000001
    li   x2,  0x7fffffff
    add  x3,  x1, x2
    li   x29, 0x80000000
    li   x30, 16
    bne  x3,  x29, fail

pass:
    li   x1,  1        # success code in x1
    j    pass          # PC loops here on success

fail:
    # x30 holds the failing test number
    j    fail          # PC loops here on failure

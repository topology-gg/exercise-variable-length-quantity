%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, signed_div_rem
from contracts.leland.util.str import (
    Str, str_hex_from_number, literal_from_number, literal_concat_known_length_dangerous)
from starkware.cairo.common.math_cmp import is_le

const RANGE_CHECK_BOUND = 2 ** 120

@view
func convert_numerical_felt_to_vlq_literal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(num : felt) -> (
        arr_len : felt, arr : felt*):
    alloc_locals

    let (arr) = alloc()
    local count

    if num == 0:
        assert count = 1
        assert [arr] = 0

        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        let (count_temp) = felt_to_vlq_recursive(num=num, last_byte=1, arr_len=0, arr=arr)
        assert count = count_temp

        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    return (count, arr)
end

@view
func felt_to_vlq_recursive{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        num : felt, last_byte : felt, arr_len : felt, arr : felt*) -> (res : felt):
    alloc_locals
    if num == 0:
        return (0)
    end

    let (local quot, local rem) = unsigned_div_rem(num, 128)
    if last_byte == 1:
        assert [arr] = rem
    else:
        assert [arr] = rem + 128
    end

    let (res) = felt_to_vlq_recursive(quot, 0, arr_len, arr + 1)
    return (res + 1)
end

@view
func convert_vlq_literal_to_numerical_felt{range_check_ptr}(vlq : felt) -> (num : felt):
    with_attr error_message(
            "convert_vlq_literal_to_numerical_felt() is not implemented in template."):
        assert 1 = 0
    end

    return (0)
end

@view
func test_add_12288_to_literal{range_check_ptr}() -> (vlq : felt):
    let literal = '0'
    let literal = literal + 12288

    return (literal)
end

@view
func test_hex_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        num : felt) -> (res : felt):
    let (res) = str_hex_from_number(num, 1)

    return (res)
end

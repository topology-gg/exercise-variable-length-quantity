%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, signed_div_rem
from contracts.leland.util.str import (
     str_concat_array, dummy_test_str_concat, Str, str_hex_from_number, literal_from_number, literal_concat_known_length_dangerous)
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

    let (new_arr : Str*) = alloc()
    let (len) = parse_through_array(count, arr, 0, new_arr, 0)
    let (new_str) = str_concat_array(len, new_arr)

    return (new_str.arr_len, new_str.arr)
end

func parse_through_array{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr} (
        prev_arr_len : felt, prev_arr : felt*, prev_i : felt, arr : Str*, i : felt) -> (len : felt):
    alloc_locals
    if i == prev_arr_len:
        return (prev_arr_len)
    end

    let curr_num = prev_arr[prev_i]
    let (hex_val) = str_hex_from_number(curr_num, 1)

    assert arr[i] = hex_val

    local next_i
    local max_len

    let (is_less_than_f) = is_le(curr_num, 15)
    ### add another "0" if less than 15
    if is_less_than_f == 1:
        let (additional_zero) = str_hex_from_number(0, 1)

        assert arr[i + 1] = additional_zero

        # Increment index and maximum length to account for extra zero
        assert next_i = i + 1
        assert max_len = prev_arr_len + 1

        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else: 
        assert next_i = i
        assert max_len = prev_arr_len

        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    let (len) = parse_through_array(max_len, prev_arr, prev_i + 1, arr, next_i + 1)
    return (len)
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
        num : felt) -> (res_len : felt, res : felt*):
    let (res) = str_hex_from_number(num, 1)
    
    return (res.arr_len, res.arr)
end

@view
func test_dummy_test_str_concat{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res_len : felt, res : felt*):
    let (res) = dummy_test_str_concat()
    
    return (res.arr_len, res.arr)
end
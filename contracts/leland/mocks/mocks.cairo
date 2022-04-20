%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, signed_div_rem
from contracts.leland.util.str import (
     get_val_from_hex, split_literal_into_str_array, concat_literals_from_str, str_concat_array, dummy_test_str_concat, Str, str_hex_from_number, literal_from_number, literal_concat_known_length_dangerous)
from starkware.cairo.common.math_cmp import is_le

const RANGE_CHECK_BOUND = 2 ** 120

from contracts.leland.vlq import parse_array_vlq_to_num, sum_arr

@view
func test_parse_array_vlq_to_num{range_check_ptr}(lit : felt) -> (arr_len : felt, arr : felt*):
    alloc_locals

    let (literal_str) = split_literal_into_str_array(lit)
    let lit_arr = literal_str.arr
    let lit_arr_len = literal_str.arr_len

    let (new_arr) = alloc()

    let (num) = parse_array_vlq_to_num(lit_arr_len, lit_arr, 0, new_arr, 0)

    return (num, new_arr)
end

@view
func test_vlq_to_num{range_check_ptr}(lit : felt) -> (sum : felt):
    alloc_locals

    let (literal_str) = split_literal_into_str_array(lit)
    let lit_arr = literal_str.arr
    let lit_arr_len = literal_str.arr_len

    let (new_arr) = alloc()

    let (new_arr_len) = parse_array_vlq_to_num(lit_arr_len, lit_arr, 0, new_arr, 0)

    let (sum) = sum_arr(new_arr_len, new_arr, 0)
    return (sum)
end

@view 
func test_get_literal_from_hex{range_check_ptr}(lit : felt) -> (val : felt):
    let (val) = get_val_from_hex(lit)

    return (val)
end

@view
func test_something() -> (num : felt):
    alloc_locals
    let (arr : felt*) = alloc()
    assert arr[24] = 1

    return (0)
end

@view
func test_split_literal_into_array{range_check_ptr}(num : felt) -> (arr_len : felt, arr : felt*):
    alloc_locals

    let (literal_arr) = split_literal_into_str_array(num)
    return (literal_arr.arr_len, literal_arr.arr)
end

@view 
func test_literal_divide{range_check_ptr}() -> (rem : felt):
    let literal = '1234'
    let (quot, rem) = unsigned_div_rem(literal, 256)

    return (rem)
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
    let (res) = str_hex_from_number(num)
    
    return (res.arr_len, res.arr)
end

@view
func test_dummy_test_str_concat{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res_len : felt, res : felt*):
    let (res) = dummy_test_str_concat()
    
    return (res.arr_len, res.arr)
end
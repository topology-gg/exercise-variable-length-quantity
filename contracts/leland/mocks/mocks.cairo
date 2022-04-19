%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, signed_div_rem
from contracts.leland.util.str import (
     split_literal_into_str_array, concat_literals_from_str, str_concat_array, dummy_test_str_concat, Str, str_hex_from_number, literal_from_number, literal_concat_known_length_dangerous)
from starkware.cairo.common.math_cmp import is_le

const RANGE_CHECK_BOUND = 2 ** 120

@view
func test_split_literal_into_array{range_check_ptr}(num : felt) -> (arr_len : felt, arr : felt*):
    alloc_locals
    let (literal) = literal_from_number(num)
    let (literal_arr) = split_literal_into_str_array(num)

    return (literal_arr.arr_len, literal_arr.arr)
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
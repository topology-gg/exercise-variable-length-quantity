%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, signed_div_rem
from contracts.leland.util.str import (
     split_literal_into_str_array, get_val_from_hex, concat_literals_from_str, str_concat_array, dummy_test_str_concat, Str, str_hex_from_number, literal_from_number, literal_concat_known_length_dangerous)
from starkware.cairo.common.math_cmp import is_le
from contracts.leland.util.math import (power)

const RANGE_CHECK_BOUND = 2 ** 120

@view
func convert_numerical_felt_to_vlq_literal{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(num : felt) -> (res : felt):
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
    let (len) = parse_array_num_to_vlq(count, arr, 0, new_arr, 0)
    let (new_str) = str_concat_array(len, new_arr)

    let (res_literal) = concat_literals_from_str(new_str)

    return (res_literal)
end

func parse_array_num_to_vlq{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr} (
        prev_arr_len : felt, prev_arr : felt*, prev_i : felt, arr : Str*, i : felt) -> (len : felt):
    alloc_locals
    if i == prev_arr_len:
        return (prev_arr_len)
    end

    let curr_num = prev_arr[prev_i]
    let (hex_val) = str_hex_from_number(curr_num)

    assert arr[i] = hex_val

    local next_i
    local max_len

    let (is_less_than_f) = is_le(curr_num, 15)
    ### add another "0" if less than 15
    if is_less_than_f == 1:
        let (additional_zero) = str_hex_from_number(0)

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

    let (len) = parse_array_num_to_vlq(max_len, prev_arr, prev_i + 1, arr, next_i + 1)
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
    alloc_locals

    let (literal_str) = split_literal_into_str_array(vlq)
    let lit_arr = literal_str.arr
    let lit_arr_len = literal_str.arr_len

    let (new_arr) = alloc()

    let (new_arr_len) = parse_array_vlq_to_num(lit_arr_len, lit_arr, 0, new_arr, 0)

    let (sum) = sum_arr(new_arr_len, new_arr, 0)
    
    return (sum)
end

func sum_arr(arr_len : felt, arr : felt*, i : felt) -> (sum : felt):
    if i == arr_len:
        return (0)
    end

    let curr_val = arr[i]
    let (sum) = sum_arr(arr_len, arr, i + 1)

    return (sum + curr_val)
end

func parse_array_vlq_to_num{range_check_ptr}(prev_arr_len : felt, prev_arr : felt*, prev_i : felt, arr : felt*, i : felt) -> (len : felt):
    alloc_locals
    if prev_i == prev_arr_len:
        return (0)
    end

    ## assume here that the literal array is reversed. i.e '8100' is ['0', '0', '1', '8']
    let lit1 = prev_arr[prev_i + 1]
    let lit2 = prev_arr[prev_i]

    let (local dec_val1) = get_val_from_hex(lit1)
    let (local dec_val2) = get_val_from_hex(lit2)

    let (byte_val_temp) = calculate_value_from_hex_byte(dec_val1, dec_val2)

    # only subtract 128 if i > 0
    let (is_less_than) = is_le(i, 0)

    local byte_val
    # not less than equal to, so is greater than
    if is_less_than == 0:
        assert byte_val = byte_val_temp - 128
    else:
        assert byte_val = byte_val_temp
    end

    let (decimal_from_base128) = calculate_decimal_from_base_128(byte_val, i)

    assert arr[i] = decimal_from_base128

    let (count) = parse_array_vlq_to_num(prev_arr_len, prev_arr, prev_i + 2, arr, i + 1)

    return (count + 1)
end

# 
# f(val, e) = val * 128^e
# f(1, 1) = 1 * 128^1
#
func calculate_decimal_from_base_128(base_128_val, e) -> (num : felt):
    let (power_val) = power(128, e)
    let res = base_128_val * power_val
    return (res)
end

# 
# f(val1 = 8, val2 = 1) -> 129
#
func calculate_value_from_hex_byte(val1 : felt, val2 : felt) -> (res : felt):
    # x = val1 * 16^1 = val1 * 16
    let x = val1 * 16

    # y = val2 * 16^0 = val2
    let y = val2

    return (x + y)
end
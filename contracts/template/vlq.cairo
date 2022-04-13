%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import signed_div_rem
from contracts.util.str import literal_from_number, literal_concat_known_length_dangerous
from starkware.cairo.common.math_cmp import is_le

const RANGE_CHECK_BOUND = 2 ** 120

@view
func convert_numerical_felt_to_vlq_literal{range_check_ptr}(num : felt) -> (vlq : felt):
    let (res, _) = felt_to_vlq_recursive(num, 0)

    return (res)
end

@view
func felt_to_vlq_recursive{range_check_ptr}(num : felt, is_last_byte : felt) -> (
        vlq : felt, vlq_len : felt):
    alloc_locals
    if is_last_byte + num == 0:
        return ('00', 2)
    else:
        if is_last_byte + num == 1:
            return ('', 0)
        end
    end

    let (local q, local r) = signed_div_rem(num, 128, RANGE_CHECK_BOUND)

    local vlq_literal
    local res_literal

    let (flag_remainder) = is_le(r, 70)  # 70 = "F"
    if flag_remainder == 1:
        let (temp) = literal_from_number(r)
        let vlq_literal_temp = temp + 12288
        assert vlq_literal = vlq_literal_temp  # i.e "6" + 12288 = "06"
    else:
        let (temp) = literal_from_number(r)
        assert vlq_literal = temp
    end

    local other_literal
    if is_last_byte == 1:
        let (temp) = literal_from_number(r + 128)
        assert other_literal = temp
        assert res_literal = other_literal
        tempvar range_check_ptr = range_check_ptr
    else:
        assert res_literal = vlq_literal
        tempvar range_check_ptr = range_check_ptr
    end

    tempvar range_check_ptr = range_check_ptr

    let (recurse_vlq, len_recurse) = felt_to_vlq_recursive(q, 1)
    let (local res) = literal_concat_known_length_dangerous(
        recurse_vlq, res_literal, len_recurse + 2)

    return (res, 0)
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

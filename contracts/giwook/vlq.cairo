%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_nn
from starkware.cairo.common.math_cmp import is_le

const zero = '0'
const overTen = 'A'

@view
func hex_to_ascii{range_check_ptr}(hex : felt) -> (ascii : felt):

    let (isOverTen) = is_le(9,hex)
    if isOverTen == 0:
        tempvar ascii = hex + zero
        return (ascii)
    else :
        tempvar ascii = hex + overTen - 10
        return (ascii)
    end

end

@view
func ascii_to_hex{range_check_ptr}(ascii : felt) -> (hex : felt):

    let (isOverTen) = is_le('A'-1,ascii)
    if isOverTen == 0:
        tempvar hex = ascii - zero
        return (hex)
    else :
        tempvar hex = ascii - overTen + 10
        return (hex)
    end

end

@view
func convert_hex_to_char {range_check_ptr}(hex : felt) -> (char : felt):
    alloc_locals

    let (local qout,local rem) = unsigned_div_rem(hex,16)

    if qout != 0:
        let (result) = convert_hex_to_char(qout)
        let (ascii) = hex_to_ascii(rem)
        return(result * 256 + ascii)
    end

    return hex_to_ascii(rem)
    
end

@view
func convert_char_to_hex {range_check_ptr}(char : felt) -> (hex : felt):
    alloc_locals

    let (local qout,local rem) = unsigned_div_rem(char,256)

    if qout != 0:
        let (result) = convert_char_to_hex(qout)
        let (hex) = ascii_to_hex(rem)
        return(result * 16 + hex)
    end

    return ascii_to_hex(rem)
    
end

@view
func convert_numerical_felt_to_vlq_literal {range_check_ptr}(num : felt) -> (vlq : felt):
    alloc_locals
    #check num is not negative
    assert_nn(num)

    #check num is smaller than 16 (it return single char)
    let (local is_under_sixten) = is_le(num,15)
    #check num is smaller than 128
    let (local is_numer_128) = is_le(num,127)

    if is_under_sixten == 1 :
        let (result) = convert_hex_to_char(num)
        #'0' + single char
        return (result+12288)
    end
    if is_numer_128 == 1 :
        let (result) = convert_hex_to_char(num)
        return (result)
    end

    #convert number to vlq
    let (result) = num2vlq(num)
    return (result)
    
end

@view
func num2vlq{range_check_ptr}(num : felt) -> (vlq : felt):
    alloc_locals
    #num/2^7
    let (local qout,local rem) = unsigned_div_rem(num,128)

    if qout != 0:
        let (temp) = num2vlq(qout)
        let (result) = convert_hex_to_char(((temp) + 128) * 256 + rem)
        return (result)
    end

    return (rem)
end

@view
func convert_vlq_literal_to_numerical_felt {range_check_ptr}(vlq : felt) -> (num : felt):
    alloc_locals

    #convert vlq str to vlq num
    let (vlq) = convert_char_to_hex(vlq)

    #convert vlq to number
    let (result) = vlq2num(vlq)
    return (result)
end

@view
func vlq2num{range_check_ptr}(vlq : felt) -> (num : felt):
    alloc_locals
    #num/2^8
    let (local qout, _) = unsigned_div_rem(vlq,256)
    #num/2^7
    let ( _,local rem) = unsigned_div_rem(vlq,128)
    
    if qout != 0:
        let (temp) = vlq2num(qout)
        let result = temp * 128 + rem
        return (result)
    end

    return (rem)
end
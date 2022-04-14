%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.util.str import Str, str_hex_from_number

@view
func test_hex_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        num : felt) -> (res : felt):
    let (res) = str_hex_from_number(num, 1)

    return (res)
end

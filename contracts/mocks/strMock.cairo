%lang starknet
from contracts.util.str import Str, str_hex_from_number

@view
func test_hex_literal{range_check_ptr}(num : felt) -> (res : felt):
    let (res) = str_hex_from_number(0, 1)
    return (res)
end

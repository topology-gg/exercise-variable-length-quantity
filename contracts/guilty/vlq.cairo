%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

@view
func convert_numerical_felt_to_vlq_literal {range_check_ptr}(
    num : felt) -> (vlq : felt):

    with_attr error_message ("convert_numerical_felt_to_vlq_literal() is not implemented in template."):
        assert 1 = 0
    end

    return (0)
end

@view
func convert_vlq_literal_to_numerical_felt {range_check_ptr}(
    vlq : felt) -> (num : felt):

    with_attr error_message ("convert_vlq_literal_to_numerical_felt() is not implemented in template."):
        assert 1 = 0
    end

    return (0)
end

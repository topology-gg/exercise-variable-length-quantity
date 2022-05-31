import pytest
import os
from starkware.starknet.testing.starknet import Starknet
import asyncio

@pytest.fixture(scope="session")
def name (pytestconfig):
    return pytestconfig.getoption("name")

def print_name (pytestconfig):
    print(f"name: {pytestconfig.getoption('name')}")

@pytest.mark.asyncio
async def test (name):

    starknet = await Starknet.empty()
    print()

    path = f'contracts/{name}/vlq.cairo'
    contract = await starknet.deploy(path)
    print(f"> Testing: {path}")

    if name == 'template':
        with pytest.raises(Exception) as e_info:
            ret = await contract.convert_numerical_felt_to_vlq_literal(0).call()
        with pytest.raises(Exception) as e_info:
            ret = await contract.convert_vlq_literal_to_numerical_felt(0).call()
        return

    #
    # Test cases
    # TODO: add more cases
    #
    test_cases = [
        {'num' : 0, 'vlq' : str_to_felt ('00')},
        {'num' : 64, 'vlq' : str_to_felt ('40')},
        {'num' : 128, 'vlq' : str_to_felt ('8100')},
        {'num' : 8192, 'vlq' : str_to_felt ('C000')},
        {'num' : 16383, 'vlq' : str_to_felt ('FF7F')}
    ]

    for case in test_cases:
        num = case['num']
        vlq = case['vlq']
        ret = await contract.convert_numerical_felt_to_vlq_literal(num).call()
        assert ret.result.vlq == vlq

    print(f" {name} has passed the test for num => vlq.")

    for case in test_cases:
         num = case['num']
         vlq = case['vlq']
         ret = await contract.convert_vlq_literal_to_numerical_felt(vlq).call()
         assert ret.result.num == num

    print(f" {name} has passed the test for vlq => name. All tests completed.")

#
# Utility function to convert short string literall to felt
# reference: https://github.com/OpenZeppelin/cairo-contracts/blob/main/tests/utils.py
#
def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")
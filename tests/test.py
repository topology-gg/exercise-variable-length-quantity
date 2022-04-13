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

    # if name == 'template':
    #     with pytest.raises(Exception) as e_info:
    #         ret = await contract.convert_numerical_felt_to_vlq_literal(0).call()
    #     with pytest.raises(Exception) as e_info:
    #         ret = await contract.convert_vlq_literal_to_numerical_felt(0).call()
    #     return

    #
    # Test cases
    # TODO: add more cases
    #
    nums = [0, 128]
    vlqs = [12336, 942747696]

    for (num, vlq) in zip (nums, vlqs):
        ret = await contract.convert_numerical_felt_to_vlq_literal(num).call()
        assert ret.result.vlq == vlq

        # ret = await contract.convert_vlq_literal_to_numerical_felt(vlq).call()
        # assert ret.result.num == num

    test_lit = await contract.test_add_12288_to_literal().invoke()
    assert test_lit.result.vlq == 12336

    print(f" {name} has passed the test.")
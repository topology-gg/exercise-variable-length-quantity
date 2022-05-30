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
    #
    nums =[0, 64, 127, 128, 16383, 16384, 2097151]
    vlqs = ['00', '40', '7F', '8100', 'FF7F', '818000', 'FFFF7F']

    for (num, vlq) in zip (nums, vlqs):
        ret = await contract.convert_numerical_felt_to_vlq_literal(num).call()
        print(f'> {num} => {ret.result.arr}')# ; {convert_asciis_into_felts(vlq)}')
        # assert ret.result.vlq == vlq

        # ret = await contract.convert_vlq_literal_to_numerical_felt(vlq).call()
        # assert ret.result.num == num

    print(f" {name} has passed the test (felt => vlq only).")


def convert_asciis_into_felts (s):
    s_reverse = s[::-1]
    l = []
    i = 0
    while(True):
        l.append( ord(s_reverse[i]) + ord(s_reverse[i+1])*256 )
        i += 2
        if i == len(s):
            break

    return l

def convert_asciis_into_felt (str):

    acc = 0
    for each in str[::-1]:
        acc = acc*256 + ord(each)

    return acc
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
    ret = await contract.test_hex_literal(0).call()
    assert ret.result.res == [48]

    # ret = await contract.test_hex_literal(127).invoke()
    # print("MY ARRAY ", get_arr(ret.result.res))
    # assert ret.result.res == [48]


    nums = [0, 64, 127, 128, 16383, 16384, 2097151]
    vlqs = [127, 1, 1, 1, 1, 1, 1]

    for (num, vlq) in zip (nums, vlqs):
        ret = await contract.convert_numerical_felt_to_vlq_literal(num).call()


        print("arr ", get_arr(ret.result.arr))
        
        # assert ret.result.arr == vlq

        # ret = await contract.convert_vlq_literal_to_numerical_felt(vlq).call()

    assert 1 == 0
    print(f" {name} has passed the test (felt => vlq only).")

def get_arr(arr):
    new_arr = []
    for i, val in enumerate(arr):
        new_arr.append(get_res_str(val))

    return new_arr

def get_res_str(val):
    return hex_to_ascii(dec_to_hex(val))
   
def dec_to_hex(num):
    return hex(num)

def hex_to_ascii(hex_str):
    asc = bytearray.fromhex(hex_str[2:]).decode()
    return asc

def fp_to_felt (val):
    val_scaled = int (val * SCALE_FP)
    if val_scaled < 0:
        val_fp = val_scaled + PRIME
    else:
        val_fp = val_scaled
    return val_fp


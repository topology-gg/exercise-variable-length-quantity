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

    path = f'contracts/leland/mocks/mocks.cairo'
    contract = await starknet.deploy(path)

    # Test cases
    # TODO: add more cases
    #
    ret = await contract.test_add_12288_to_literal().invoke()
    assert get_res_str(ret.result.vlq) == "00"

    print(f"passed tests")

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

import pytest
import os
from starkware.starknet.testing.starknet import Starknet
import asyncio
from binascii import hexlify

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
    # ret = await contract.test_add_12288_to_literal().invoke()
    # assert get_res_str(ret.result.vlq) == "00"

    # ret = await contract.test_literal_divide().call()
    # assert get_res_str(ret.result.rem) == "4"

    # val = get_felt_from_ascii("123")
    # ret = await contract.test_split_literal_into_array(val).call()
    # assert get_arr(ret.result.arr) == ["3", "2", "1"]

    # val = get_felt_from_ascii("0")
    # ret = await contract.test_split_literal_into_array(val).call()
    # assert get_arr(ret.result.arr) == ["0"]

    # val = get_felt_from_ascii("00")
    # ret = await contract.test_split_literal_into_array(val).call()
    # assert get_arr(ret.result.arr) == ["0", "0"]

    # ret = await contract.test_get_literal_from_hex(get_felt_from_ascii("0")).call()
    # assert ret.result.val == 0

    # ret = await contract.test_get_literal_from_hex(get_felt_from_ascii("A")).call()
    # assert ret.result.val == 10

    # ret = await contract.test_parse_array_vlq_to_num(get_felt_from_ascii("8100")).invoke()
    # assert ret.result.arr == [0]

    ret = await contract.test_vlq_to_num(get_felt_from_ascii("8100")).invoke()
    assert ret.result.sum == 128


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

def get_felt_from_ascii(val):
    return hex_to_dec(ascii_to_hex(val))

def hex_to_dec(h):
    return int(h, 16)

def ascii_to_hex(string):
    h = hexlify(string.encode())
    return h

def fp_to_felt (val):
    val_scaled = int (val * SCALE_FP)
    if val_scaled < 0:
        val_fp = val_scaled + PRIME
    else:
        val_fp = val_scaled
    return val_fp


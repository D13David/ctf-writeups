from web3 import Web3
from solcx import compile_source

base_path = "./blockchain_navigating_the_unknown/"

with open(base_path + "Setup.sol") as f:
    setup = f.read()
with open(base_path + "Unknown.sol") as f:
    unknown = f.read()

setup_abi = compile_source(setup, output_values=["abi"], base_path=base_path)["<stdin>:Setup"]["abi"]
unknown_abi = compile_source(unknown, output_values=["abi"], base_path=base_path)["<stdin>:Unknown"]["abi"]

print(unknown_abi)

w3 = Web3(Web3.HTTPProvider("http://64.227.41.83:31467"))
print(w3.is_connected())

address = "0xF73DFAd642C8d4da4429E38735A3dF6c130B228D"
contract = w3.eth.contract(address=address, abi=unknown_abi)
print(contract.functions.updateSensors(10).transact())

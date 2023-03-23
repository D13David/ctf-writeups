# Cyber Apocalypse 2023

## Navigating the Unknown

> Your advanced sensory systems make it easy for you to navigate familiar environments, but you must rely on intuition to navigate in unknown territories. Through practice and training, you must learn to read subtle cues and become comfortable in unpredictable situations. Can you use your software to find your way through the blocks?
>
>  Author: N/A
>
> [`blockchain_navigating_the_unknown.zip`](blockchain_navigating_the_unknown.zip)

Tags: _blockchain_

## Solution
This is an introductory challenge to blockchain. The way to solve this is to interact with one of two given contracts:

```
pragma solidity ^0.8.18;


contract Unknown {
    
    bool public updated;

    function updateSensors(uint256 version) external {
        if (version == 10) {
            updated = true;
        }
    }

}
```
When started two docker images are spawned. One with deployed contracts that, that can be used as provider and one that simply is an interface to get connectivity informations an get the flag. 

First up fetching the connectivity information

```
$ nc 159.65.94.38 30761
1 - Connection information
2 - Restart Instance
3 - Get flag
action? 1

Private key     :  0x031690a9e237dee859a06b8688a01e1d347983c2a25d4925836028301610d0e4
Address         :  0x7242e5325FcbCF2E0e56b526D65C452E86b9654d
Target contract :  0x7C99652145fBeFB8dbeBb4CFa6Afb92EfEfbFc66
Setup contract  :  0x61ad3DDcb62c96B20c06eD5ccd574a92C5248b35
```

Setting up a quick [`script`](solution.py) using web3py to call the method and set version to 10.

```
contract = w3.eth.contract(address=address, abi=unknown_abi)
print(contract.functions.updateSensors(10).transact())
```

After the contract is in correct state the flag can be retrieved
```
$ python solution.py
$ nc 159.65.94.38 30761
1 - Connection information
2 - Restart Instance
3 - Get flag
action? 2

HTB{9P5_50FtW4R3_UPd4t3D}
```


# Cyber Apocalypse 2024

## Russian Roulette

> Welcome to The Fray. This is a warm-up to test if you have what it takes to tackle the challenges of the realm. Are you brave enough?
> 
> Author: perrythepwner
> 
> [`blockchain_russian_roulette.zip`](blockchain_russian_roulette.zip)

Tags: _blockchain_

## Solution
For this challenge we get two [`Solidity`](https://soliditylang.org/) scripts:

```js
pragma solidity 0.8.23;

import {RussianRoulette} from "./RussianRoulette.sol";

contract Setup {
    RussianRoulette public immutable TARGET;

    constructor() payable {
        TARGET = new RussianRoulette{value: 10 ether}();
    }

    function isSolved() public view returns (bool) {
        return address(TARGET).balance == 0;
    }
}

pragma solidity 0.8.23;

contract RussianRoulette {

    constructor() payable {
        // i need more bullets
    }

    function pullTrigger() public returns (string memory) {
        if (uint256(blockhash(block.number - 1)) % 10 == 7) {
            selfdestruct(payable(msg.sender)); // 💀
        } else {
                return "im SAFU ... for now";
            }
    }
}
```

`Setup` is deployed as one target and `RussianRoulette`. To win the flag the condition for `isSolved` needs to be given, meaning the `RussianRoulette` contract should have a balance of `0`. Looking at `pullTrigger` we see a call to `selfdestruct`. The documentation states `selfdestruct sends all remaining Ether stored in the contract to a designated address.` ([`selfdestruct`](https://solidity-by-example.org/hacks/self-destruct/)), so we have just to invoke `pullTrigger` enought times until we hit the right condition. Doing this, gives us the flag.

Flag `HTB{99%_0f_g4mbl3rs_quit_b4_bigwin}`

## Lucky Faucet

> The Fray announced the placement of a faucet along the path for adventurers who can overcome the initial challenges. It's designed to provide enough resources for all players, with the hope that someone won't monopolize it, leaving none for others.
> 
> Author: perrythepwner
> 
> [`blockchain_lucky_faucet.zip`]blockchain_lucky_faucet.zip)

Tags: _blockchain_

## Solution
Like in the previous challenge [`Russian Roulette`](README.md#russian-roulette) we have two contracts `Setup` and `LuckyFaucet`.

```js
pragma solidity 0.7.6;

import {LuckyFaucet} from "./LuckyFaucet.sol";

contract Setup {
    LuckyFaucet public immutable TARGET;

    uint256 constant INITIAL_BALANCE = 500 ether;

    constructor() payable {
        TARGET = new LuckyFaucet{value: INITIAL_BALANCE}();
    }

    function isSolved() public view returns (bool) {
        return address(TARGET).balance <= INITIAL_BALANCE - 10 ether;
    }
}

pragma solidity 0.7.6;

contract LuckyFaucet {
    int64 public upperBound;
    int64 public lowerBound;

    constructor() payable {
        // start with 50M-100M wei Range until player changes it
        upperBound = 100_000_000;
        lowerBound =  50_000_000;
    }

    function setBounds(int64 _newLowerBound, int64 _newUpperBound) public {
        require(_newUpperBound <= 100_000_000, "100M wei is the max upperBound sry");
        require(_newLowerBound <=  50_000_000,  "50M wei is the max lowerBound sry");
        require(_newLowerBound <= _newUpperBound);
        // why? because if you don't need this much, pls lower the upper bound :)
        // we don't have infinite money glitch.
        upperBound = _newUpperBound;
        lowerBound = _newLowerBound;
    }

    function sendRandomETH() public returns (bool, uint64) {
        int256 randomInt = int256(blockhash(block.number - 1)); // "but it's not actually random 🤓"
        // we can safely cast to uint64 since we'll never
        // have to worry about sending more than 2**64 - 1 wei
        uint64 amountToSend = uint64(randomInt % (upperBound - lowerBound + 1) + lowerBound);
        bool sent = msg.sender.send(amountToSend);
        return (sent, amountToSend);
    }
}
```

We can see the win condition is that the blance of the `TARGET` contract should be `10 ether` less than the initial value of `500 ether`. In the solidity script of `LuckyFaucet` we see that we can send a random amout of `eth` to a sender. The random value ranges from `50.000.000 to 100.000.000 wei`, since `500 ether` are `500.000.000.000.000.000.000` we only send small fractions on every invoke.

But we are able to set the range, we cannot go higher than `100.00.000 wei` but we can go way lower. If we set the lower bound to a very huge negative number (like `-100.000.000.000.000` or so) our range increases drastically and since we cast to an `uint64` we flip the sign and spend an large amount on every `sendRandomETH` call. Doing this, gives us the flag.

Flag `HTB{1_f0rg0r_s0m3_U}`
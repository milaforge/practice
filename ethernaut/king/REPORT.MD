[<- Back](../../README.md)

# Security Review Report (King)


## Project Overview
The King smart contract; is a means to choose the highest bidder as the king. 

### Logic Bug
The owner (the one who deploys the Smart Contract) can bypass the rules and litteraly kick in the ass of the current king, without returning their true prize.

[Here](./src/King.sol#L16) is where the Owner can change the king without bidding higher:
```solidity
require(msg.value >= prize || msg.sender == owner);
```

### Code Bug
1) Use pull instead of push. The mechanism used to transfer king prize uses push. instead of pushing the prize, we should use pulling. that means enable the previous king to `claim` their bid instead of transferring (pushing) their bid;


2) And [here](./src/King.sol#L17) is where the prize could be manupulated by the owner by setting the `msg.value` to 0:
```solidity
payable(king).transfer(msg.value);
```

3) Miscalculating the prize 

The previous king will **receive more** than they bid; 
The fix:

```diff
payable(king).transfer(
-    msg.value
+    prize
);
```


# Proof of Concept

## Overview
Instead of EOA, we create a special smart contract account that does not include any functionality to handle receiving ETH (though it could still receive ETH from `selldestruct` or `precomputed address`, out of the scope here); so when we became the new king, we would stay the king, no matter what.


## Pre Setup
Deploy the [special smart contract](./src/King.e.sol).

```sh
cast wallet import anvil --interactive # import your account

forge script KingScript --account anvil --rpc-url localhost:8545 # Dry run

forge script KingScript --account anvil --rpc-url localhost:8545 --broadcast # Execute
```
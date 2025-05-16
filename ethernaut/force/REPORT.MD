[<- Back](../../README.md)

# Security Review Report (Force)


## Project Overview
In solidity, contracts can choose to not receive Ether (to an extent);
This contract shows one of the two methods possible to bypass this limitation:
1. sending Ether to a contract address that is not deployed yet (precompute its address)
2. set the contract address as the selfdestruct destination


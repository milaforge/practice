[<- Back](../../README.md)

# Security Review Report (CoinFlip)

## Table of Contents
1. [Project Overview](#project-overview)
   - [Problem Statement](#problem-statement)
2. [Vulnerable Lines of Code](#vulnerable-lines-of-code)
3. [Vulnerability Details](#vulnerability-details)
   - [Root Cause Analysis](#root-cause-analysis)
   - [Steps to Reproduce](#steps-to-reproduce)
4. [Impact](#impact)
   - [Potential Exploits](#potential-exploits)
5. [Proof of Concept](#proof-of-concept)
6. [Remediation](#remediation)
7. [References](#references)


## Project Overview
This is a coin flipping game where you need to build up your winning streak by guessing the outcome of a coin flip. To complete this level you'll need to use your psychic abilities to guess the correct outcome 10 times in a row.

### Problem Statement
The smart contract is designed to illustrate a common vulnerability in the CoinFlip game, where the predictability of randomness can be exploited. This report aims to guide developers in identifying and mitigating such vulnerabilities in Ethereum smart contracts to enhance security.

## Vulnerable Lines of Code

- [Weak Randomness Source](./src/CoinFlip.sol#L14-21)

## Vulnerability Details

The CoinFlip contract utilizes the block hash of the previous block to determine the outcome of the coin flip. This introduces **predictability** in the randomness, allowing attackers to potentially predict the outcome of the flip. Since the block hash is publicly available, an attacker can calculate it in advance and predict the result of the coin flip, gaining an unfair advantage.

```solidity
function flip() public {
    uint256 blockHash = uint256(blockhash(block.number - 1)); //! Predictable randomness
    uint256 coinFlip = blockhashValue / CONSTANT_FACTOR;
    bool side = coinFlip == 1 ? true : false;
    // Contract logic based on outcome
}
```

### Root Cause Analysis

The use of `blockhash(block.number - 1)` as a source of randomness introduces predictability. The Ethereum network's block hash can be known to anyone after a block is mined, meaning attackers can calculate the outcome of the coin flip before it occurs. This violates the principles of secure randomness and makes the contract vulnerable to exploitation.

### Steps to Reproduce

1. Deploy the CoinFlip contract on a test network.
2. Call the `flip()` function and observe the outcome.
3. Using the block hash of the previous block `(blockhash(block.number - 1))`, calculate the result of the coin flip before calling the function to predict the outcome.
---

## Impact

The predictability of the coin flip outcome exposes the contract to attacks where an adversary can consistently win the coin flip, potentially resulting in financial loss for the contract owner or participants. This undermines the integrity and trust in the smart contract.

### Potential Exploits

1. An attacker could predict the outcome of the coin flip by analyzing the block hash and consistently win, gaining a financial advantage.
---

## Proof of Concept
> [Reference Implementation](./test/CoinFlipExploit.t.sol#L8).


## Remediation

1. Integrate Chainlink VRF (Verifiable Random Function) to generate secure, unpredictable randomness for the coin flip outcome. Ensure the contract properly verifies the randomness before using it.
---

## References

- [EIP-1052: Description](https://eips.ethereum.org/EIPS/eip-1052)
- [Other Reference: Description](<INSERT_LINK>)

[<- Back](../../README.md)

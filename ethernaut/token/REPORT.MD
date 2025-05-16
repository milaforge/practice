[<- Back](../../README.md)

# Security Review Report (Token)

## Table of Contents
1. [Project Overview](#project-overview)
2. [Security Issues](#security-issues)
    - [Issue 1: unchecked underflow vulnerability](#issue-1-ownership-takeover-vulnerability)
3. [Proof of Concept](#proof-of-concept)
4. [Remediation](#remediation)
7. [References](#references)


## Project Overview
The `Token` contract mints some predefined amount to the deployer. the receiver can transfer it to any address via `transfer`, but it has a vulnerability that allows to transfer a very large amount of token to the receipient, enabling potential exploitation.

## Security Issues
The `transfer` function does have an underflow vulnerability. The check in require(balances[msg.sender] - _value >= 0); doesn't prevent underflow effectively in Solidity versions prior to 0.8.0 because subtraction operations do not revert on underflow.


## Proof of Concept
> [Reference Implementation](./script/Token.s.sol).

## Remediation
The correct way to mitigate this vulnerability is to explicitly check require(balances[msg.sender] >= _value);.

```diff
    function transfer(address _to, uint256 _value) public returns (bool) {
-       require(balances[msg.sender] - _value >= 0);
+       require(balances[msg.sender] >= _value);
        owner = _owner;
    }
```

## References
- [Ethernaut Telephone Documentation](https://ethernaut.openzeppelin.com/level/5)

[<- Back](../../README.md)

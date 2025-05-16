[<- Back](../../README.md)

# Security Review Report (Telephone)

## Table of Contents
1. [Project Overview](#project-overview)
    - [Problem Statement](#problem-statement)
    - [Intended Use](#intended-use)
2. [Security Issues](#security-issues)
    - [Issue 1: Ownership Takeover Vulnerability](#issue-1-ownership-takeover-vulnerability)
3. [Proof of Concept](#proof-of-concept)
4. [Remediation](#remediation)
    - [Implement Ownership Checks](#implement-ownership-checks)
5. [Conclusion](#conclusion)
6. [Glossary](#glossary)
7. [References](#references)


## Project Overview
The `Telephone` contract sets the deployer as the owner and allows ownership transfer via `changeOwner`, but it has a vulnerability that lets anyone change the owner if called from a different address, enabling potential exploitation.

### Problem Statement
The Telephone contract lets anyone change the owner if tx.origin differs from msg.sender. An attacker can exploit this by using a malicious contract to take control.

### Intended Use
The contract is intended for use by developers and security researchers as an educational resource, emphasizing the importance of secure randomness in smart contract development.

## Security Issues

### Issue 1: Ownership Takeover Vulnerability
- **Description**: The Telephone contract allows ownership changes based on the condition that `tx.origin` differs from `msg.sender`, which can be exploited.
- **Exploitation**: An attacker can deploy a malicious contract that calls `changeOwner`, bypassing the intended ownership checks and taking control of the contract.
- **Consequences**: This vulnerability can lead to unauthorized ownership transfers, resulting in potential financial loss and loss of control over the contract for the legitimate owner.

## Proof of Concept
> [Reference Implementation](./test/Telephone.t.sol#L8).

## Remediation

### Implement Ownership Checks
- **Action**: Modify the `changeOwner` function to restrict ownership changes to only the current owner by checking `msg.sender` against the `owner` variable. This will prevent unauthorized ownership transfers.

```diff
    function changeOwner(address _owner) public {
+       require(msg.sender == owner, "Only the owner can change the owner");
        owner = _owner;
    }
```

- **Expected Outcome**: This enhancement will secure the contract against exploitation, ensuring that only the legitimate owner can change the ownership, thereby strengthening its security.

## Conclusion
In conclusion, the Telephone contract serves as an important educational example of the need for proper access control in smart contracts. By implementing the recommended changes to restrict ownership transfers, developers can significantly enhance the security of their contracts and mitigate potential exploits.

## Glossary
- **Smart Contract**: A self-executing contract with the terms of the agreement directly written into code.
- **Exploit**: Taking advantage of a vulnerability in a system to cause unintended behavior.
- **Mitigation**: Actions taken to reduce the severity or likelihood of a security issue.

## References
- [Ethernaut Telephone Documentation](https://ethernaut.openzeppelin.com/level/4)
- [OpenZeppelin Ownable Contract](https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable)

[<- Back](../../README.md)

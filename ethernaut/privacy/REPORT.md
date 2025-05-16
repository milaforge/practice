[<- Back](../../README.md)

**Vulnerability Report**

**Title:** Unsecured Storage in Smart Contract (Ethernaut Privacy - Contract: Privacy.sol)

**Summary:**
A vulnerability was identified in the Ethernaut Privacy contract, allowing for unauthorized access to private data stored within the contract.

**Affected Contract(s):**
The affected contract is [Privacy.sol](./src/Privacy.sol).

**Vulnerability Details:**
The vulnerability resides in the storage layout of the contract. Specifically, it involves the lack of proper protection mechanisms for private variables. The contract's design allows for any user to access and read any storage slot using a common web3 provider.

**Proof of Concept (PoC):**
To demonstrate the vulnerability, we created a simple [PoC](./script/Privacy.s.sol). We used a common web3 provider to interact with the contract and read any storage slot freely. This exploitation was possible because the keys are mistakenly kept private on the smart contract storage.

**Impact:**
The identified vulnerability allows for full exposure of private data stored within the contract. This poses significant risks to users, as sensitive information could be accessed by unauthorized parties.

**Recommended Mitigation:**
To address this vulnerability, we recommend implementing off-chain storage for secrets. This involves using external data storage solutions that are not tied to the blockchain, thereby protecting user privacy and reducing the risk of exposure.


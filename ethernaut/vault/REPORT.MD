[<- Back](../../README.md)

# Security Review Report (Vault)


## Project Overview
In solidity, private variable are not secure! all data on blockchain are public; 
contracts storage can be read:

```
web3.eth.getStorageAt(contractAddress, slotIndex)
```

or in foundry utilizing the `vm` cheatcode:

```
vm.load(ADDRESS, SLOT_NO)

```
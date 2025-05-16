Title: No Privacy in Smart Contract
Protocol: Ethernaut Privacy
Contract: Privacy.sol
Bug Type: Storage Layout
PoC: use common web3 provider to read any storage slot freely.
Impact: full exposure of private data
Mitigation: use off-chain storage to keep secrets.
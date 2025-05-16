[<- Back](../../README.md)

# Security Review Report (Reentrancy)


## ❌ Vulnerability

### 1. Pre-0.8 Solidity lacks overflow/underflow checks
In older Solidity versions, `balances[msg.sender] - 1` when balance is `0` wraps to `2**256 - 1`.

### 2. Incorrect operation order in withdraw() 
The contract transfers value(ETH) before updating the sender’s balance, violating the _checks-effects-interactions_ pattern.

-> [Code reference](./src/Reentrance.sol#L16)

> Because the external call occurs before the internal state update, a malicious contract can re-enter withdraw() and drain funds before the balance is reduced.
## 💥 Impact

Any address with a non-zero balance can:
* Repeatedly exploit `withdraw()` through a fallback function.
* Drain the entire contract balance.

> This vulnerability requires no special permissions. It’s especially critical in public ETH-holding contracts (vaults, treasuries, etc.).

## 📚 Context
This bug belongs to a broader class of state-inconsistency vulnerabilities caused by:
* Trusting external calls before internal state mutation.
* Failing to isolate side effects (common in `call`, `delegatecall`, `send`).
Such bugs are prevalent in older _Solidity_ versions and beginner contracts.


## ✅ Recommended Fix
### 1. Reorder logic: checks → effects → interactions:

```diff
if (balances[msg.sender] >= _amount) {
-    (bool result,) = msg.sender.call{value: _amount}("");
    balances[msg.sender] -= _amount;
+    (bool result,) = msg.sender.call{value: _amount}("");
}

```

### 2. Use Solidity ≥0.8.0 for native overflow protection:
If using older versions, import _OpenZeppelin_'s _SafeMath_:

```diff
- balances[msg.sender] -= _amount;
+ balances[msg.sender] = balances[msg.sender].sub(_amount);
```

### 3. Optional: Add _nonReentrant_ modifier
Using _OpenZeppelin_’s _ReentrancyGuard_ can add an additional layer of safety in complex contracts.

[<- Back](../../README.md)

# Security Review Report (Force)

## TL;DR

The `Force` contract declares no payable `receive` or `fallback` function, so ordinary direct Ether transfers are rejected. That does not guarantee a zero balance: Ether can be forced into any address by creating a contract whose constructor executes `selfdestruct(target)` while holding Ether. The included exploit sends `1 ether` to `Force` during deployment.

## Contract and Intended Invariant

The target contract in [`src/Force.sol`](./src/Force.sol) contains no executable functions and no payable entry point:

```solidity
contract Force {
    // receive() payable external {}
}
```

The challenge's implicit assumption is that the target balance remains zero because it cannot receive Ether through a normal call. That assumption is invalid at the EVM account level: an account's balance can change without executing code at the recipient address.

## Vulnerability Details

### Forced Ether transfer through `selfdestruct`

The exploit contract is defined in [`src/Force.e.sol`](./src/Force.e.sol):

```solidity
contract ForceExploit {
    constructor(address payable target) payable {
        selfdestruct(target);
    }
}
```

When `ForceExploit` is deployed with a non-zero value, its constructor immediately executes `selfdestruct(target)`. The EVM transfers the contract's remaining Ether balance to `target` without calling `target` and without requiring a payable `receive` or `fallback` function.

The target therefore receives the Ether even though `Force` cannot accept a normal `address(force).call{value: ...}("")` transfer.

### The recipient cannot reject the transfer

The transfer is a protocol-level balance update rather than a message call to `Force`. No recipient code runs, so `Force` has no opportunity to revert it. The same principle applies to other balance changes that do not use the recipient's payable interface, such as mining rewards on networks that support them and certain protocol-level operations.

### Alternative pre-funded address technique

Another approach is to precompute a contract address, send Ether to that address before deployment, and then deploy the contract at the precomputed address. This is not used by the repository's PoC; the constructor `selfdestruct` path is the demonstrated exploit.

## Attack Flow

1. Deploy `Force` and confirm its balance is zero.
2. Fund the attacker or exploit deployment with Ether.
3. Deploy `ForceExploit` with `1 ether` and the `Force` address as `target`.
4. The constructor executes `selfdestruct(target)`.
5. The EVM credits `Force` with the exploit contract's balance without calling `Force`.
6. Verify that `address(force).balance == 1 ether`.

The test implements this flow:

```solidity
vm.deal(address(this), 1 ether);
new ForceExploit{value: 1 ether}(payable(address(force)));
assertEq(address(force).balance, 1 ether);
```

See [`test/Force.t.sol`](./test/Force.t.sol#L15-L23).

## Impact

The target balance can become non-zero despite the absence of payable code. Any logic that treats `address(this).balance == 0` as an invariant can therefore be bypassed.

Potential consequences include:

- balance-based state checks becoming false;
- accounting discrepancies between internal records and native Ether balance;
- permanently stranded Ether when the contract has no withdrawal function; and
- incorrect assumptions in access-control, withdrawal, or solvency logic.

This primitive does not by itself grant the attacker control of `Force`, and it does not automatically make the Ether withdrawable. Impact depends on how the receiving contract uses its native balance.

## Root Cause

The root cause is confusing the absence of a payable entry point with an enforceable balance invariant. Solidity-level receive/fallback functions govern ordinary message-call transfers, but they do not control every EVM mechanism that can credit an address.

## Recommended Remediation

### Do not use native balance as an exclusive accounting source

Track application deposits and withdrawals in explicit state variables. Treat `address(this).balance` as an external observable that may be greater than the internally accounted amount.

### Handle excess Ether deliberately

If the contract can safely recover unsolicited Ether, provide a restricted mechanism for handling the excess balance. Separate accounted funds from unaccounted funds and emit events for recovery operations.

### Design checks around the actual invariant

Do not write security or business logic that assumes the contract balance can never increase unexpectedly. If a zero balance is genuinely required, recognize that a deployed contract cannot generally enforce this invariant against forced transfers.

### Note on modern EVM semantics

Post-Cancun EVMs changed `SELFDESTRUCT` so that it generally no longer deletes an existing contract except in the same transaction in which it was created. The balance-transfer behavior relevant to this challenge remains sufficient to force Ether to the target. Deployments should still account for chain-specific fork rules.

## Validation

Run the challenge test from `ethernaut/force`:

```bash
forge test
```

The test should verify that `Force` starts with a zero balance and ends with `1 ether` after deploying `ForceExploit`.

## Conclusion

`Force` cannot prevent Ether from reaching its address merely by omitting payable functions. The included constructor-based `selfdestruct` exploit demonstrates why native account balances are not fully controlled by recipient code. Contracts should use explicit internal accounting and treat unsolicited Ether as an expected boundary condition.

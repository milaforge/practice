[<- Back](../../README.md)

# Security Review Report (Delegation)

## TL;DR

`Delegation` forwards arbitrary calldata to a `Delegate` contract with `delegatecall`. Delegated code executes in the caller's storage context, so an attacker can invoke `pwn()` through the fallback and corrupt proxy state. The fallback has no selector allowlist or authorization check.

## Contracts and Intended Design

The contracts are defined in [`src/Delegate.sol`](./src/Delegate.sol):

- `Delegate` exposes `pwn()`, which assigns `owner = msg.sender`.
- `Delegation` stores an owner and delegate address, then forwards unknown calls to that delegate.

`Delegation` initializes its owner to the deployer and is expected to preserve that authorization boundary.

## Vulnerability Details

### Arbitrary delegatecall through the fallback

The fallback forwards every calldata payload:

```solidity
fallback() external {
    (bool result, ) = address(delegate).delegatecall(msg.data);
    if (result) {
        this;
    }
}
```

There is no function-selector allowlist, caller check, or access-control check. A caller can therefore submit the selector for `Delegate.pwn()` even though `Delegation` does not declare a `pwn()` function.

### Storage collision and execution context

`delegatecall` executes target bytecode while preserving `address(this)`, `msg.sender`, `msg.value`, and the caller's storage. The relevant layouts are:

| Slot | `Delegate` | `Delegation` |
| --- | --- | --- |
| `0` | `opa` | `owner` |
| `1` | `owner` | `delegate` |

This layout mismatch means `Delegate.pwn()` writes to slot 1 of `Delegation`, which is the `delegate` address rather than `owner`. The call therefore corrupts the configured delegate in the current source. In a proxy design, the same class of collision can overwrite ownership, the implementation address, or other configuration. Storage compatibility must be explicitly designed and reviewed; it cannot be inferred from matching variable names.

Inside delegated `pwn()`, `msg.sender` remains the external attacker rather than the `Delegate` contract. Any delegated authorization logic consequently runs with the attacker's identity.

### Revert handling is incomplete

The fallback ignores the delegatecall's return data and does nothing when `result` is false. Callers receive no useful revert reason, and operational failures are harder to detect.

## Attack Flow

1. Identify the deployed `Delegation` address.
2. Encode the zero-argument selector for `pwn()`.
3. Send that calldata directly to `Delegation`.
4. The fallback forwards it with `delegatecall`.
5. The delegated code writes to `Delegation` storage using the attacker's caller identity.
6. The configured delegate address is corrupted in the current source; a compatible-but-unsafe layout could instead expose ownership or other privileged state.

The repository test performs the call with:

```solidity
(bool success, ) = address(delegation).call(
    abi.encodeWithSignature("pwn()")
);
```

See [`test/Delegate.t.sol`](./test/Delegate.t.sol#L20-L25).

## Impact

An unprivileged account can reach arbitrary delegated code and corrupt proxy state. In an asset-bearing or upgradeable contract, this can enable unauthorized administration, implementation replacement, fund loss, permanent denial of service, or state corruption. Severity is **Critical** when the pattern protects funds, upgrades, or administrative operations. For the exact source shown here, the demonstrated `pwn()` call corrupts the delegate pointer; the repository test's owner-change assertion does not match the declared storage layout and requires correction before an owner takeover can be claimed.

## Root Cause

The root cause is treating arbitrary `delegatecall` as a safe forwarding mechanism. The contract combines arbitrary calldata, shared storage, preserved caller identity, and no compatibility or authorization boundary.

## Recommended Remediation

### Prefer explicit function calls

Declare the required functions directly and authorize them before state changes. Avoid a generic fallback for privileged behavior.

### Use a reviewed proxy standard when upgradeability is required

Use a standard such as ERC-1967 or ERC-1822 with a documented storage layout, a dedicated implementation slot, protected upgrades, initialization protection, and implementation compatibility checks.

### Restrict forwarding and propagate failures

If forwarding is unavoidable, allowlist selectors, validate the target, restrict administrative selectors, and revert with returned delegatecall error data when the call fails.

### Do not use arbitrary contracts as libraries

A standalone contract with public state-changing functions must not be treated as a trusted library. Its bytecode, storage assumptions, and upgrade path must be reviewed with the caller.

## Validation

Run the challenge test from `ethernaut/delegate`:

```bash
forge test
```

The test is intended to demonstrate the delegated call, but it currently asserts that the target owner changes even though `owner` is slot 0 and `pwn()` writes slot 1. That assertion should be corrected to check the delegate pointer or the contract layout should be changed intentionally before treating the test as proof of owner takeover. In the current checkout, `forge test` is blocked because the `forge-std` dependency is not available.

## Conclusion

`Delegation` exposes a privileged execution boundary through an unrestricted fallback. The current layout makes the supplied `pwn()` payload corrupt the delegate pointer, while the test overstates the impact by asserting an owner change. Because `delegatecall` combines implementation code with caller storage and identity, the pattern remains unsafe without strict selector, authorization, and storage-layout controls.

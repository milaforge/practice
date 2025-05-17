[<- Back](../../README.md)

# Security Review Report (Vault)

## TL;DR

`Vault` uses the Solidity `private` visibility modifier for a password, but
private state is not secret on a public blockchain. Any observer can read the
contract's storage slot directly, recover the password, and call `unlock()`.

## Contract and Intended Invariant

[`src/Vault.sol`](./src/Vault.sol) stores a lock flag and password:

```solidity
bool public locked;
bytes32 private password;
```

The constructor sets `locked` to `true`, and `unlock()` is intended to clear the
lock only when the correct password is supplied.

## Vulnerability Details

### `private` does not provide confidentiality

Solidity visibility controls access from Solidity source code. It does not hide
state from RPC clients, block explorers, archive nodes, or anyone able to query
the contract's storage. The value remains part of the chain state and can be
read with `eth_getStorageAt` or equivalent tooling.

### Storage layout exposes the password

The state variables occupy these slots:

| Slot | Variable | Value |
| --- | --- | --- |
| `0` | `locked` | `true` or `false` |
| `1` | `password` | the `bytes32` password |

An attacker reads slot `1`, obtains the password, and supplies it to the public
`unlock(bytes32)` function. No authorization check limits who may call it.

## Attack Flow

1. Identify the deployed `Vault` address.
2. Read storage slot `1` through an RPC provider.
3. Decode the returned 32-byte value as the password.
4. Call `unlock(recoveredPassword)` from any account.
5. Verify that `locked()` returns `false`.

The repository test demonstrates the storage read using Foundry's `vm.load`:

```solidity
bytes32 read = vm.load(address(vault), bytes32(uint(1)));
assertEq(read, password);
```

See [`test/Vault.t.sol`](./test/Vault.t.sol#L16-L20).

## Impact

Any party can recover the supposed secret and bypass the lock. The impact is a
complete loss of confidentiality for the password and a complete bypass of the
contract's unlock condition. If `locked` protects withdrawals, upgrades, or
other privileged operations in a real system, this can lead to unauthorized
state changes or asset loss.

## Root Cause

The contract treats source-level visibility as an encryption or access-control
mechanism. Blockchain storage is publicly observable, so a password stored in a
`private` variable is retrievable by design.

## Recommended Remediation

### Do not store secrets on-chain

Keep passwords and other confidential material off-chain. If the contract needs
to verify a secret, prefer a protocol that does not publish the secret itself,
such as an appropriate commitment/reveal scheme or a zero-knowledge proof.

### Use real authorization

For administrative unlocking, use explicit access control, such as a role or a
carefully designed signature-based authorization. Do not rely on an on-chain
password as the sole control for sensitive operations.

### Consider replay and front-running

Any plaintext secret or unlock transaction submitted to the public mempool can
be observed and copied. Authorization designs should bind approvals to the
intended contract, operation, caller, and nonce where appropriate.

## Validation

Run the challenge test from `ethernaut/vault`:

```bash
forge test
```

The storage test should confirm that slot `1` contains the constructor password.

## Conclusion

`Vault` cannot protect a password by marking it `private`. Its state is public,
and the password can be read directly before calling `unlock()`. Confidential
values must remain off-chain or be represented by a cryptographic protocol that
does not expose the secret in contract storage.

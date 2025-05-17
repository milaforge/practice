[<- Back](../../README.md)

# Security Review Report (Privacy)

## TL;DR

`Privacy` stores three `bytes32` values in a `private` array and later uses the third value as an unlock key. The `private` modifier does not hide blockchain storage. Anyone can read `data[2]` from storage slot `5`, truncate it to `bytes16`, and call `unlock()`.

## Contract and Intended Invariant

The affected contract is [`src/Privacy.sol`](./src/Privacy.sol). It initializes the contract as locked and expects the key passed to `unlock(bytes16)` to remain private:

```solidity
bytes32[3] private data;

function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
}
```

The intended invariant is that only a party possessing the private key can set `locked` to `false`.

## Vulnerability Details

### Private storage is publicly readable

Solidity's `private` visibility restricts access from other Solidity contracts; it does not encrypt or conceal the value from RPC callers. Every storage slot can be queried by anyone with access to the chain data.

### Storage layout reveals the key location

The variables are laid out as follows:

| Slot | Contents |
| --- | --- |
| `0` | `locked` |
| `1` | `ID` |
| `2` | `flattening`, `denomination`, and `awkwardness` packed together |
| `3` | `data[0]` |
| `4` | `data[1]` |
| `5` | `data[2]` |

For the Solidity types in this contract, `data[2]` is the complete 32-byte value at slot `5`. The unlock function only compares the first 16 bytes, so the attacker needs only `bytes16(storageAt(privacyAddress, 5))`.

### Public unlock path

`unlock()` has no caller restriction. Once the storage value is read, any account can submit the recovered `bytes16` value and pass the `require` check.

## Attack Flow

1. Identify the deployed `Privacy` address.
2. Read storage slot `5` using an RPC provider or node tooling.
3. Take the first 16 bytes of the returned `bytes32` value.
4. Call `unlock(bytes16Key)` from any account.
5. Verify that `locked()` returns `false`.

The test uses the same key value supplied during deployment:

```solidity
privacy.unlock(bytes16(key));
assert(privacy.locked() == false);
```

See [`test/Privacy.t.sol`](./test/Privacy.t.sol#L20-L22). In a real deployment, the same value would be recovered from slot `5` rather than from local test state.

## Impact

Any observer can recover the key material stored in `data[2]` and unlock the contract. This is a complete failure of the intended confidentiality and authorization boundary. If unlocking controls funds, upgrades, or other privileged behavior, an attacker can trigger those operations without authorization.

The vulnerability does not expose arbitrary off-chain secrets; it exposes the specific on-chain value that the contract incorrectly treats as private.

## Root Cause

The contract relies on Solidity visibility instead of cryptographic secrecy. It also uses a directly stored plaintext value as an authorization secret and provides a public state-changing function with no caller authentication.

## Recommended Remediation

### Never store plaintext secrets on-chain

Move confidential key material off-chain. If the protocol needs to verify knowledge of a secret, use a commitment/reveal design or a suitable zero-knowledge proof rather than storing the secret itself.

### Use explicit authorization

Protect unlocking with a role, an authenticated signature, or another audited authorization mechanism. Bind signatures to the contract, chain, operation, nonce, and intended caller where replay protection is required.

### Avoid mempool-disclosed secrets

Passing a plaintext key in a public transaction exposes it to observers. A secret submitted directly to `unlock()` can be copied and replayed unless the protocol uses an appropriate one-time or cryptographically bound mechanism.

## Validation

Run the challenge test from `ethernaut/privacy`:

```bash
forge test
```

The test confirms the lock transition using the known constructor key. A full storage-read PoC should additionally read slot `5` from a deployed instance and derive the `bytes16` argument from that result.

## Conclusion

`Privacy` does not provide privacy for its `data` array. The key is permanently observable in public storage, and the unrestricted `unlock()` function makes that exposure directly exploitable. Confidentiality must come from off-chain storage or a cryptographic protocol, not from the Solidity `private` keyword.

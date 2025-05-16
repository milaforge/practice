[<- Back](../../README.md)

# Security Review Report (Gatekeeper One)

## Summary

`GatekeeperOne.enter` can be called by an attacker through a proxy contract. The three gates are bypassed using a proxy, a selected gas limit, and an encoded `uint64` key.

## Affected Contract

- [`GK.sol`](./src/GK.sol)
- [`enter(address _entrant)`](./src/GK.sol#L11)

## Vulnerability Details

### Gate one: caller confusion

The `msg.sender != tx.origin` check rejects a direct EOA call, but a proxy satisfies it because `msg.sender` is the proxy while `tx.origin` is the attacker.

### Gate two: attacker-controlled gas

The `gasleft() % 8191` check is not a security boundary. The attacker can retry with different gas limits until the remainder matches the required value.

### Gate three: predictable key constraint

The key is derived from the caller's address bits. An attacker can construct a `uint64` value whose low 16 bits match `uint16(uint160(tx.origin))` and whose upper bits satisfy the remaining inequality.

## Proof of Concept

The exploit is implemented in [`test/GK.t.sol`](./test/GK.t.sol):

1. Deploy a proxy so `msg.sender != tx.origin`.
2. Construct a key from the caller's low 16 address bits.
3. Brute-force the gas limit until gate two succeeds.
4. Call `enter` through the proxy and verify the entrant.

## Impact

An unprivileged account can become the recorded entrant, defeating the intended access-control challenge. In production, `tx.origin` authorization and gas-dependent checks would be unreliable security controls.

## Recommended Mitigation

- Do not use `tx.origin` for authorization; use explicit access control or signatures.
- Do not use `gasleft()` as an authentication or integrity check.
- Replace address-bit puzzles with a clear, auditable caller authorization rule.

## Validation

Run the included Foundry test from this directory:

```bash
forge test
```

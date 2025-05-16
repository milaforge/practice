# The Elevator Bug

## TL;DR

The elevator contract is designed to prevent users from going to the last floor. However, because the Building interface is controlled by the caller, a malicious contract can trick the elevator into allowing access to any floor—including the last one. This demonstrates a security risk where **trusting external contract logic** can break intended restrictions.

## Implementation Details

There is an `Elevator` Contract with two public variables:

- `top` (bool)
- `floor` (uunt256)

The `goTo` function takes a `_floor` input and:

1. casts `msg.sender` into a `Building` interface, assuming the caller is another contract that implements `isLastFloor(uint256) external returns (bool)`.
2. It calls `building.isLastFloor(_floor)`.
3. If the result is false, it sets `floor = _floor`.
4. Then it calls `building.isLastFloor(floor)` again and sets `top` to that value.

## Now, why does this feel _wrong_?

1. Casting `msg.sender` to `Building` interface directly is dangerous.
   Solidity allows this, but it blindly assumes the sender is trustworthy and implements that function properly.

   > Any contract could implement a malicious `isLastFloor`!

2. `building.isLastFloor` is called twice, but the function could behave differently each time.
   `isLastFloor` might return different values depending on internal state of the calling contract!
   It is not required to be a `pure` or `view` function here (no `view` or `pure` keyword is enforced).
   It could **mutate state**, or do weird things.

3. `isLastFloor` is trusted to report truth, but that's naive.
   The `Elevator` contract trusts the return value of a completely _external_, user-controlled function.

4. The sequence matters.
   In the first call, if `isLastFloor(_floor)` returns `false`, `floor` is updated.
   Then immediately after, it calls `isLastFloor(floor)` again, but by this time, the attacker can change its response.

Check out the [security report](./REPORT.MD) for a concise breakdown.

# Ethernaut CoinFlip.

- Install required packages
```bash 
$ forge install
$ yarn install --frozen-lockfile 
```

- Duplicate and rename [.env.example](.env.example) to `.env`, then populate the necessary environment variables (e.g., `RPC_LOCAL`, `PK`, `TARGET_CONTRACT_ADDRESS`).

```bash
$ yarn run prepare
```

- Get the Exploit Contract address and put it in the `.env` -> `TARGET_CONTRACT_ADDRESS`.

```bash
$ yarn run exploit
```

- Or exploit manually:
```bash 
$ forge script script/2.ManualExecuteExploit.sol --rpc-url $RPC_LOCAL --private-key $PK
```

### Test

```shell
$ forge test
```

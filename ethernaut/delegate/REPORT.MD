[<- Back](../../README.md)

# Security Review Report (Delegate)

## Project Overview
This project demonsrates why in order to reuse codes, we should utilize libraries instead of Contracts.
When you delegatecall from Contract A to Contract B, the code in Contract B will have access to Contract A storage layout; any modification to the storage layout will modify Contract A.

So use libraries that are stateless and safe from this kind of attacks.
 
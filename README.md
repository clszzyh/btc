# Basic bitcoin library

[![ci](https://github.com/clszzyh/btc/workflows/ci/badge.svg)](https://github.com/clszzyh/btc/actions)
[![Documentation](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://clszzyh.github.io/btc)
![Lines of code](https://img.shields.io/tokei/lines/github/clszzyh/btc)

<!-- MDOC -->

Bitcoin P2PK, P2PKH, P2SH, P2WPKH, P2WSH script/address generate and validate demo.

**Supported**

* P2PKH
* P2SH
* P2WPKH
* P2WSH

## Usage

```elixir
entropy = Btc.Util.strong_rand()
{:ok, {priv_key, address}} = Btc.Address.generate(:p2pkh, :mainnet, entropy)
true = Btc.Address.verify?(:p2pkh, :mainnet, address)
```

```elixir
{:ok, {priv_key, address}} = Btc.Address.generate(:p2sh, :mainnet)
true = Btc.Address.verify?(:p2sh, :mainnet, address)
```

```elixir
{:ok, {priv_key, address}} = Btc.Address.generate(:p2wpkh, :testnet)
true = Btc.Address.verify?(:p2wpkh, :testnet, address)
```
<!-- MDOC -->

## Reference

### Prefix
* https://en.bitcoin.it/wiki/List_of_address_prefixes

## Overview
* https://bitcoin.stackexchange.com/questions/93966/getting-public-key-from-any-raw-transaction-what-to-take-care-of
* https://bitcoin.stackexchange.com/questions/64733/what-is-p2pk-p2pkh-p2sh-p2wpkh-eli5

### Address
* https://en.bitcoin.it/wiki/Invoice_address

### P2PKH
* https://en.bitcoinwiki.org/wiki/Pay-to-Pubkey_Hash

### P2SH
* https://en.bitcoin.it/wiki/Pay_to_script_hash
* https://en.bitcoin.it/wiki/BIP_0016

## Other
* https://en.bitcoin.it/wiki/Script#Opcodes

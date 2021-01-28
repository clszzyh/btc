defmodule BtcTest do
  use ExUnit.Case
  doctest Btc
  doctest Btc.Util
  doctest Btc.Base58Check
  doctest Btc.Addresses.P2pkh
  # doctest Btc.Addresses.P2sh
  # doctest Btc.Addresses.P2wpkh
  # doctest Btc.Addresses.P2wsh
end

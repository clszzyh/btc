defmodule Btc.Addresses.P2sh do
  @moduledoc """
  ## Links

  * https://en.bitcoin.it/wiki/Pay_to_script_hash
  * https://en.bitcoin.it/wiki/BIP_0016
  * https://en.bitcoin.it/wiki/List_of_address_prefixes

  ## ScriptPubKey and ScriptSig Display

      scriptSig: [signature] {[pubkey] OP_CHECKSIG}
      scriptPubKey: OP_HASH160 [20-byte-hash of {[pubkey] OP_CHECKSIG} ] OP_EQUAL

  ## Summary

  * mainnet
    * prefix: `5`
    * leading symbol: `3`
    * example: `3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX`
  * testnet
    * prefix: `196`
    * leading symbol: `2`
    * example: `2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc`
  """

  use Btc.Address

  @network_prefixes %{mainnet: <<5>>, testnet: <<196>>}
  @network_prefix_keyword Keyword.new(@network_prefixes)

  @impl true
  def type, do: :p2sh

  @impl true
  def generate_address(entropy, _) do
    {:error, entropy}
  end

  @doc """
  ## Example

      iex> #{__MODULE__}.address_valid?("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX", :mainnet)
      true
      iex> #{__MODULE__}.address_valid?("2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc", :testnet)
      true
      iex> #{__MODULE__}.address_valid?("foo", :mainnet)
      false
  """
  @impl true
  def address_valid?(address, network) do
    address |> Base58Check.decode() |> address_valid_1?(network)
  end

  defp address_valid_1?({:ok, {prefix, _}}, network)
       when {network, prefix} in @network_prefix_keyword,
       do: true

  defp address_valid_1?(_, _), do: false
end

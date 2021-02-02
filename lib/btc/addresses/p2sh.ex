defmodule Btc.Addresses.P2sh do
  @moduledoc """
  ## Links

  * https://en.bitcoin.it/wiki/Pay_to_script_hash
  * https://en.bitcoin.it/wiki/BIP_0016
  * https://en.bitcoin.it/wiki/List_of_address_prefixes
  * https://en.bitcoin.it/wiki/Script#Opcodes

  ## ScriptPubKey and ScriptSig Display

      scriptSig: [signature] {[pubkey] OP_CHECKSIG}
      scriptPubKey: OP_HASH160 [20-byte-hash of {[pubkey] OP_CHECKSIG} ] OP_EQUAL

  ## Struct

      A 1 of 1 multisig transaction is created by concatenating the following byte values:

      OP_0 0x14 HASH160( K )

      A = BASE58CHECK( 0x05 HASH160( OP_0 0x14 HASH160( K ) ) )
      Where 0x05 is the version byte for script hash addresses and 0x14 is
      the amount of bytes to expect in the HASH160( K ).

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
  @op_0 <<0>>

  @impl true
  def type, do: :p2sh

  @impl true
  def generate_address(entropy, network) do
    with {:ok, private_key} <- Address.generate_private_key(entropy),
         {:ok, public_key} <- Address.create_public_key(private_key),
         {:ok, address} <- generate_address_1(network, public_key) do
      {:ok, {private_key, address}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp generate_address_1(network, public_key) when is_map_key(@network_prefixes, network) do
    transaction = @op_0 <> <<0x14>> <> Util.hash160(public_key)
    Base58Check.encode(@network_prefixes[network], Util.hash160(transaction))
  end

  defp generate_address_1(_, _), do: {:error, :error_network}

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

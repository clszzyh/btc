defmodule Btc.Addresses.P2pkh do
  @moduledoc """
  Pay-to-Public-Key-Hash

  ## Links

  * https://en.bitcoinwiki.org/wiki/Pay-to-Pubkey_Hash
  * https://en.bitcoin.it/wiki/List_of_address_prefixes
  * https://bitcoin.stackexchange.com/questions/72775/is-it-possible-to-convert-an-address-from-p2pkh-to-p2sh

  ## ScriptPubKey and ScriptSig Display

      ScriptPubKey= OP_DUP OP_HASH160 <Public KeyHash> OP_EQUAL OP_CHECKSIG
      ScriptSig= <Signature> <Public Key>

  ## Struct

      A = BASE58CHECK( 0x00 HASH160( K ) )
      Where HASH160( K ) is equivalent to RIPEMD160( SHA256( K ) )
      and 0x00 represents the version byte (for P2PKH)

  ## Summary

  * mainnet
    * prefix: `0`
    * leading symbol: `1`
    * example: `17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem`
  * testnet
    * prefix: `111`
    * leading symbol: `m or n`
    * example: `mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn`
  """

  use Btc.Address

  @network_prefixes %{mainnet: <<0>>, testnet: <<111>>}
  @network_prefix_keyword Keyword.new(@network_prefixes)

  @impl true
  def type, do: :p2pkh

  @doc """
  ## Example

      iex> #{__MODULE__}.generate_address(<<0::big-256>>, :mainnet)
      {:error, 'Public key generation error'}
      iex> entropy = <<72, 160, 32, 203, 107, 197, 248, 91, 227, 205, 37, 63, 217, 112, 82, 227, 131, 44, 56, 160, 180, 66, 7, 116, 181, 203, 125, 58, 172, 54, 181, 102>>
      iex> {:ok, {priv_key, mainnet_address}} = #{__MODULE__}.generate_address(entropy, :mainnet)
      iex> {:ok, {^priv_key, testnet_address}} = #{__MODULE__}.generate_address(entropy, :testnet)
      ...> {mainnet_address, testnet_address, byte_size(priv_key)}
      {"1EmCKjrbhRJ7znmCg1LRTjZ5nHHxSVhUqJ", "muH9cnwaWSjNmuEpPaJoHemQeGtfPJRV5R", 32}
  """
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
    Base58Check.encode(@network_prefixes[network], Util.hash160(public_key))
  end

  defp generate_address_1(_, _), do: {:error, :error_network}

  @doc """
  ## Example

      iex> #{__MODULE__}.address_valid?("17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem", :mainnet)
      true
      iex> #{__MODULE__}.address_valid?("mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn", :testnet)
      true
      iex> #{__MODULE__}.address_valid?("foo", :mainnet)
      false
  """
  @impl true
  def address_valid?(address, network) do
    address |> Base58Check.decode() |> address_valid_1?(network)
  end

  defp address_valid_1?({:ok, {prefix, payload}}, network)
       when {network, prefix} in @network_prefix_keyword and byte_size(payload) == 20,
       do: true

  defp address_valid_1?(_, _), do: false
end

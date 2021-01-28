defmodule Btc.Addresses.P2wpkh do
  @moduledoc """
  ## Links

  * https://en.bitcoin.it/wiki/BIP_0173
  * https://en.bitcoin.it/wiki/BIP_0141#P2WPKH

  ## Summary
  `0 <20-byte-key-hash>`
  """

  use Btc.Address

  @impl true
  def type, do: :p2wpkh

  @impl true
  def generate_address(entropy, _) do
    {:error, entropy}
  end

  @doc """
  ## Example

      iex> #{__MODULE__}.address_valid?("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4", :mainnet)
      true
      iex> #{__MODULE__}.address_valid?("tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx", :testnet)
      true
      iex> #{__MODULE__}.address_valid?("foo", :mainnet)
      false
  """
  @impl true
  def address_valid?(address, network) do
    address |> Bech32.decode() |> address_valid_1?(network)
  end

  ## credo:disable-for-next-line
  ## TODO check data size
  # defp address_valid_1?({:ok, network, _, data}, network) when byte_size(data) == 20, do: true
  defp address_valid_1?({:ok, network, _, _data}, network), do: true
  defp address_valid_1?(_, _), do: false
end

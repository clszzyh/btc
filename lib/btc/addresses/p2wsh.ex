defmodule Btc.Addresses.P2wsh do
  @moduledoc """
  ## Links
  * https://en.bitcoin.it/wiki/BIP_0173
  * https://en.bitcoin.it/wiki/BIP_0141#P2WSH

  ## Summary

  `0 <32-byte-hash>`
  """

  use Btc.Address

  @impl true
  def type, do: :p2wsh

  @impl true
  def generate_address(entropy, _) do
    {:error, entropy}
  end

  @doc """
  ## Example

      iex> #{__MODULE__}.address_valid?("bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3", :mainnet)
      true
      iex> #{__MODULE__}.address_valid?("tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7", :testnet)
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
  # defp address_valid_1?({:ok, network, _, data}, network) when byte_size(data) == 32, do: true
  defp address_valid_1?({:ok, network, _, _data}, network), do: true
  defp address_valid_1?(_, _), do: false
end

defmodule Btc.Addresses.P2wpkh do
  @moduledoc """
  Pay-to-Witness-Public-Key-Hash

  ## Links

  * https://en.bitcoin.it/wiki/BIP_0173
  * https://en.bitcoin.it/wiki/BIP_0141#P2WPKH
  * https://en.bitcoin.it/wiki/BIP_0142
  # https://en.bitcoin.it/wiki/BIP_0144
  * https://en.bitcoin.it/wiki/List_of_address_prefixes
  * https://programmingblockchain.gitbook.io/programmingblockchain/other_types_of_ownership/p2wpkh_pay_to_witness_public_key_hash

  ## Summary

  For P2WPKH address, the address version is 6 (0x06) for a
  main-network address or 3 (0x03) for a testnet address.

  `0 <20-byte-key-hash>`

  * mainnet
    * prefix: `bc`
    * example: `bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4`
  * testnet
    * testnet: `tb`
    * example: `tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx`
  """

  use Btc.Address

  @network_prefixes %{mainnet: "bc", testnet: "tb"}
  @address_versions %{mainnet: <<6>>, testnet: <<3>>}

  ## The witness program version is a 1-byte value between 0 (0x00)
  ## and 16 (0x10). Only version 0 is defined in BIP141. Versions 1 to
  ## 16 are reserved for future extensions.
  @witness_version <<0>>
  @op_0 <<0>>

  @impl true
  def type, do: :p2wpkh

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
    data = @address_versions[network] <> @witness_version <> @op_0 <> Util.hash160(public_key)
    {:ok, Bip0173.encode(@network_prefixes[network], data)}
  end

  defp generate_address_1(_, _), do: {:error, :error_network}

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
    address |> Bip0173.decode() |> address_valid_1?(network)
  end

  ## credo:disable-for-next-line
  ## TODO check data size
  # defp address_valid_1?({:ok, network, _, data}, network) when byte_size(data) == 20, do: true
  defp address_valid_1?({:ok, network, _, _data}, network), do: true
  defp address_valid_1?(_, _), do: false
end

defmodule Btc.Addresses.P2wsh do
  @moduledoc """
  Pay-To-Witness-Script-Hash

  ## Links

  * https://en.bitcoin.it/wiki/BIP_0173
  * https://en.bitcoin.it/wiki/BIP_0141#P2WSH
  * https://en.bitcoin.it/wiki/BIP_0142
  * https://en.bitcoin.it/wiki/List_of_address_prefixes
  * https://programmingblockchain.gitbook.io/programmingblockchain/other_types_of_ownership/p2wsh_pay_to_witness_script_hash

  ## Summary

  For P2WSH address, the address version is 10 (0x0A) for a
  main-network address or 40 (0x28) for a testnet address.

  `0 <32-byte-hash>`

  * mainnet
    * prefix: `bc`
    * example: `bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3`
  * testnet
    * testnet: `tb`
    * example: `tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7`
  """

  use Btc.Address

  @network_prefixes %{mainnet: "bc", testnet: "tb"}
  @address_versions %{mainnet: <<0x0A>>, testnet: <<0x28>>}
  ## The witness program version is a 1-byte value between 0 (0x00)
  ## and 16 (0x10). Only version 0 is defined in BIP141. Versions 1 to
  ## 16 are reserved for future extensions.
  @witness_version <<0>>
  @op_0 <<0>>

  @impl true
  def type, do: :p2wsh

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
    data = @address_versions[network] <> @witness_version <> @op_0 <> Util.hash160(transaction)
    {:ok, Bip0173.encode(@network_prefixes[network], data)}
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
    address |> Bip0173.decode() |> address_valid_1?(network)
  end

  ## credo:disable-for-next-line
  ## TODO check data size
  # defp address_valid_1?({:ok, network, _, data}, network) when byte_size(data) == 32, do: true
  defp address_valid_1?({:ok, network, _, _data}, network), do: true
  defp address_valid_1?(_, _), do: false
end

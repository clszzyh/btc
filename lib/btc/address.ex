defmodule Btc.Address do
  @external_resource readme = Path.join([__DIR__, "../../README.md"])
  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(1)

  alias Btc.Util

  @type_modules %{
    p2pkh: Btc.Addresses.P2pkh,
    p2sh: Btc.Addresses.P2sh,
    p2wpkh: Btc.Addresses.P2wpkh,
    p2wsh: Btc.Addresses.P2wsh
  }

  @types Map.keys(@type_modules)

  @networks [:testnet, :mainnet]

  @type type :: unquote(Enum.reduce(@types, &{:|, [], [&1, &2]}))

  @type entropy :: String.t()
  @typedoc """
  * https://en.bitcoin.it/wiki/Testnet
  """
  @type network :: unquote(Enum.reduce(@networks, &{:|, [], [&1, &2]}))
  @type address :: String.t()

  @type compression :: :compressed | :uncompressed

  @type private_key :: <<_::256>>
  @type public_key :: String.t()

  @type generate_result ::
          {:ok, {private_key :: private_key(), address :: address}} | {:error, atom()}

  @doc "Return type of current module"
  @callback type :: type()
  @doc "Given a 32 bytes random binary and a network type, return a valid bitcoin address."
  @callback generate_address(entropy :: entropy(), network :: network()) :: generate_result
  @doc "Given a address and a network type, check if the address is valid"
  @callback address_valid?(address :: address, network :: network()) :: boolean()

  defmacro __using__(_opts) do
    quote do
      alias unquote(__MODULE__)
      alias Btc.Base58Check
      alias Btc.Bip0173
      alias Btc.Util
      @behaviour unquote(__MODULE__)

      @before_compile unquote(__MODULE__)
    end
  end

  @spec generate(type :: type(), network :: network(), entropy :: entropy()) ::
          generate_result
  def generate(type, network, entropy \\ Util.strong_rand()) when type in @types do
    @type_modules[type].generate_address(entropy, network)
  end

  @spec valid?(type :: type(), network :: network, address :: String.t()) :: boolean()
  def valid?(type, network, address) when type in @types do
    @type_modules[type].address_valid?(address, network)
  end

  @spec generate_private_key(entropy :: String.t()) :: {:ok, private_key :: private_key()}
  def generate_private_key(entropy) do
    {:ok, Util.generate_private_key(entropy)}
    # :libsecp256k1.ec_privkey_export(entropy, compression)
  end

  @doc """
  https://github.com/mbrix/libsecp256k1/blob/master/test/libsecp256k1_tests.erl
  """
  @spec create_public_key(private_key :: private_key(), compression :: compression) ::
          {:ok, public_key()} | {:error, term}
  def create_public_key(private_key, compression \\ :compressed) do
    :libsecp256k1.ec_pubkey_create(private_key, compression)
  end

  defmacro __before_compile__(env) do
    doctest = """
    ## Doctest mainnet

        iex> network = :mainnet
        ...> entropy = Btc.Util.strong_rand()
        ...> {:ok, {_priv_key, address}} = #{env.module}.generate_address(entropy, network)
        ...> #{env.module}.address_valid?(address, network)
        true

    ## Doctest testnet

        iex> network = :testnet
        ...> entropy = Btc.Util.strong_rand()
        ...> {:ok, {_priv_key, address}} = #{env.module}.generate_address(entropy, network)
        ...> #{env.module}.address_valid?(address, network)
        true
    """

    case Module.get_attribute(env.module, :moduledoc) do
      {_, binary} when is_binary(binary) ->
        quote do
          @moduledoc unquote(binary <> "\n\n" <> doctest)
        end

      {_, false} ->
        quote do
        end
    end
  end
end

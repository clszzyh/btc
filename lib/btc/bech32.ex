defmodule Btc.Bech32 do
  @moduledoc """
  ## Summary

      Bech32 is a segwit address format specified by BIP 0173. This
      address format is also known as "bc1 addresses". Bech32 is more
      efficient with block space. As of October 2020, the Bech32
      address format is supported in many popular wallets and is the
      preferred address scheme

  ## Example

      Examples of the address format being used on mainnet are the
      TXIDs
      4ef47f6eb681d5d9fa2f7e16336cd629303c635e8da51e425b76088be9c8744c
      and
      514a33f1d46179b89e1fea7bbb07b682ab14083a276979f91038369d1a8d689b. And
      addresses bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq and
      bc1qc7slrfxkknqcq2jevvvkdgvrt8080852dfjewde450xdlk4ugp7szw5tk9.

  """

  alias Btc.Address

  @network_map %{"bc" => :mainnet, "tb" => :testnet}

  @doc """

  Software interpreting a segwit address:
  * MUST verify that the human-readable part is "bc" for mainnet and "tb" for testnet.
  * MUST verify that the first decoded data value (the witness version) is between 0 and 16, inclusive.

  https://github.com/f2pool/bech32-elixir/blob/master/lib/bech32.ex#L257
  https://en.bitcoin.it/wiki/Bech32
  https://en.bitcoin.it/wiki/BIP_0173

  ## Example

      iex> match?({:ok, :mainnet, 3, _}, #{__MODULE__}.decode("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"))
      true
  """
  @spec decode(b :: String.t()) ::
          {:ok, network :: Address.network(), witness_version :: integer(), data :: String.t()}
          | {:error, reason :: atom()}
  def decode(data) do
    with {:ok, data} <- decode_basic(data),
         {:ok, data} <- decode_ord(data),
         {:ok, hrp, data} <- decode_split(data),
         # {:ok, hrp, data} <- decode_checksum(hrp, data),
         {:ok, network, witness_version, data} <- decode_network(hrp, data) do
      {:ok, network, witness_version, data}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @separator "1"
  @charsets (for c <- ~c(qpzry9x8gf2tvdw0s3jn54khce6mua7l), reduce: {%{}, 0} do
               {map, i} -> {Map.put(map, c, <<i>>), i + 1}
             end)
            |> elem(0)

  defp decode_network(hrp, <<witness_version::8, rest::binary>>)
       when is_map_key(@network_map, hrp) and witness_version in 0..16,
       do: {:ok, @network_map[hrp], witness_version, rest}

  defp decode_network(hrp, _), do: {:error, "unknown hrp: #{inspect(hrp)}"}

  defp decode_split(data) do
    data
    |> String.reverse()
    |> String.split(@separator, parts: 2)
    |> case do
      [data_reverse, hrp_reverse] ->
        case for <<c <- data_reverse>>, !is_map_key(@charsets, c), do: c do
          [] ->
            {:ok, String.reverse(hrp_reverse),
             String.reverse(for <<c <- data_reverse>>, into: "", do: @charsets[c])}

          ary ->
            {:error, "Error char: #{inspect(ary)}"}
        end

      _ ->
        {:error, :split_error}
    end
  end

  ## https://github.com/sipa/bech32/blob/master/ref/ruby/bech32.rb#L35
  defp decode_basic(data) do
    cond do
      String.contains?(data, :binary.compile_pattern(["?"])) -> {:error, :invalid_input}
      data != String.upcase(data) and data != String.downcase(data) -> {:error, :mixed_case_error}
      String.length(data) > 90 -> {:error, :length_exceed_limit}
      true -> {:ok, String.downcase(data)}
    end
  end

  ## https://github.com/sipa/bech32/blob/master/ref/ruby/bech32.rb#L41
  defp decode_ord(data) do
    error_chars = for <<c::8 <- data>>, c < 33 or c > 126, do: c

    case error_chars do
      [] -> {:ok, data}
      [first | _] -> {:error, "invalid char: #{first}"}
    end
  end
end

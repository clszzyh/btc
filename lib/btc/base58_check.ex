defmodule Btc.Base58Check do
  @moduledoc """
  https://en.bitcoin.it/wiki/Base58Check_encoding
  http://lenschulwitz.com/base58

  ## Creating a Base58Check string

  * Take the version byte and payload bytes, and concatenate them
    together (bytewise).
  * Take the first four bytes of SHA256(SHA256(results of step 1))
  * Concatenate the results of step 1 and the results of step 2
    together (bytewise).
  * Treating the results of step 3 - a series of bytes - as a single
    big-endian bignumber, convert to base-58 using normal mathematical
    steps (bignumber division) and the base-58 alphabet described
    below. The result should be normalized to not have any leading
    base-58 zeroes (character '1').
  * The leading character '1', which has a value of zero in base58, is
    reserved for representing an entire leading zero byte, as when it
    is in a leading position, has no value as a base-58 symbol. There
    can be one or more leading '1's when necessary to represent one or
    more leading zero bytes. Count the number of leading zero bytes
    that were the result of step 3 (for old Bitcoin addresses, there
    will always be at least one for the version/application byte; for
    new addresses, there will never be any). Each leading zero byte
    shall be represented by its own character '1' in the final result.
  * Concatenate the 1's from step 5 with the results of step 4. This
    is the Base58Check result.
  """

  alias Btc.Util

  @doc """
  """
  @spec encode(version :: String.t(), payload :: String.t()) :: {:ok, String.t()}
  def encode(version, payload) do
    data = version <> payload
    {:ok, encode_1(data <> Util.checksum(data))}
  end

  defp encode_1(<<0, rest::binary>>), do: Base58.encode(<<0>>) <> encode_1(rest)
  defp encode_1(binary), do: Base58.encode(binary)

  @doc """
  ## Example

      iex> #{__MODULE__}.decode("17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem")
      {:ok, {<<0>>, <<71, 55, 108, 111, 83, 125, 98, 23, 122, 44, 65, 196, 202, 155, 69, 130, 154, 185, 144, 131>>}}
  """
  @spec decode(b :: String.t()) ::
          {:ok, {version :: String.t(), data :: String.t()}} | {:error, reason :: atom()}
  def decode(binary) do
    with check_target <- decode_1(binary),
         {:ok, v} <- decode_verify(check_target, byte_size(check_target) - 4),
         {:ok, version, payload} <- decode_version(v) do
      {:ok, {version, payload}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp decode_1("1" <> rest), do: Base58.decode("1") <> decode_1(rest)
  defp decode_1(binary), do: Base58.decode(binary)

  defp decode_verify(data, payload_size) do
    case data do
      <<payload::binary-size(payload_size), checksum::binary-size(4)>> ->
        if checksum == Util.checksum(payload) do
          {:ok, payload}
        else
          {:error, :checksum_error}
        end

      _ ->
        {:error, :extract_error}
    end
  end

  # https://en.bitcoin.it/wiki/List_of_address_prefixes
  @versions [
    <<0>>,
    <<5>>,
    <<128>>,
    <<4, 136, 178, 30>>,
    <<4, 136, 173, 228>>,
    <<111>>,
    <<196>>,
    <<239>>,
    <<4, 53, 135, 207>>,
    <<4, 53, 131, 148>>
  ]

  for v <- @versions do
    defp decode_version(unquote(v) <> rest), do: {:ok, unquote(v), rest}
  end

  defp decode_version(_), do: {:error, :version_error}
end

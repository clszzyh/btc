defmodule Btc.Util do
  @moduledoc false

  @ecdsa_sec256k1_max 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
  @phash2_range 100

  @doc """
  ## Example

      iex> match?(i when i in 0..#{@phash2_range}, #{__MODULE__}.phash2)
      true
  """

  def phash2 do
    :erlang.phash2(strong_rand(), @phash2_range)
  end

  @doc """
  * https://en.bitcoin.it/wiki/Allprivatekeys

  max_private_key: #{@ecdsa_sec256k1_max}

  ## Example

      iex> byte_size(#{__MODULE__}.generate_private_key())
      32
  """
  @spec generate_private_key(h :: String.t(), p :: 0..unquote(@phash2_range)) :: <<_::256>>
  def generate_private_key(h \\ strong_rand(), p \\ phash2())

  if Mix.env() == :test do
    def generate_private_key(h, _), do: h
  else
    def generate_private_key(h, -1), do: h

    def generate_private_key(h, p) do
      <<t::big-256>> = h = sha256(h)
      p = if t > @ecdsa_sec256k1_max, do: p, else: p - 1
      generate_private_key(h, p)
    end
  end

  @spec sha256(String.t()) :: <<_::256>>
  def sha256(o) do
    :crypto.hash(:sha256, o)
  end

  @spec ripemd160(String.t()) :: <<_::160>>
  def ripemd160(o) do
    :crypto.hash(:ripemd160, o)
  end

  def hash160(o) do
    ripemd160(sha256(o))
  end

  def strong_rand(bytes \\ 32) do
    :crypto.strong_rand_bytes(bytes)
  end

  @spec checksum(String.t()) :: <<_::32>>
  def checksum(o) do
    <<s::binary-size(4), _rest::binary>> = o |> sha256() |> sha256()
    s
  end
end

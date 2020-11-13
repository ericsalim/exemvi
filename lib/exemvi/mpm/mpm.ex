defmodule Exemvi.MPM do

  def parse(payload) do
    case parse_rest(payload, []) do
      {:error, reason} -> {:error, reason}
      {:ok, tlvs} -> {:ok, Enum.reverse(tlvs)}
    end
  end

  defp parse_rest("", tlvs) do
    {:ok, tlvs}
  end

  defp parse_rest(payload, tlvs) do
    datob = payload |> String.slice(0, 2)
    datlen = payload |> String.slice(2, 2)

    with {datlen_int, _} <- payload
                            |> String.slice(2, 2)
                            |> Integer.parse()
    do
      datval = String.slice(payload, 4, datlen_int)
      tlvs_new =
        [
          %Exemvi.TLV
          {
            data_object: datob,
            data_length: datlen,
            data_value: datval
          }
          | tlvs
        ]
      rest = String.slice(payload, (4+datlen_int)..-1)
      parse_rest(rest, tlvs_new)
    else
      :error -> {:error, Exemvi.Error.invalid_data_length}
    end
  end
end

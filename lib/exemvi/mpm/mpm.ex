defmodule Exemvi.MPM do

  @moduledoc """
  Helpers for MPM (Merchant Presented Mode)
  """
  def parse(payload) do
    case parse_rest(payload, []) do
      {:error, reason} -> {:error, reason}
      {:ok, tlvs} -> {:ok, Enum.reverse(tlvs)}
    end
  end

  def validate(tlvs) do
    {:error, []}
  end

  def validate(tlvs, :mandatory) do
    data_object_atoms = Enum.map(
      tlvs,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) end)

    mandatories = Exemvi.MPM.DataObject.mandatories()

    errors = Enum.reduce(
      mandatories,
      [],
      fn x, acc -> data_object_exists(data_object_atoms, x, acc) end)

    case Enum.count(errors) do
      0 -> {:ok, nil}
      _ -> {:error, errors}
    end
  end

  defp parse_rest("", tlvs) do
    {:ok, tlvs}
  end

  defp parse_rest(payload, tlvs) do
    with data_object = payload |> String.slice(0, 2),
         {data_length, _} <- payload
                             |> String.slice(2, 2)
                             |> Integer.parse()
    do
      data_value = String.slice(payload, 4, data_length)
      tlvs_new =
        [
          %Exemvi.TLV
          {
            data_object: data_object,
            data_value: data_value
          }
          | tlvs
        ]

      rest = String.slice(payload, (4 + data_length)..-1)
      parse_rest(rest, tlvs_new)
    else
      :error -> {:error, [Exemvi.Error.invalid_data_length]}
    end
  end

  defp data_object_exists(data_object_atoms, atom, errors) do
    if Enum.member?(data_object_atoms, atom) do
      errors
    else
      [Exemvi.Error.missing_data_object(atom) | errors]
    end
  end

end

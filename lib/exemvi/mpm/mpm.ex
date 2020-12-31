defmodule Exemvi.MPM do

  @moduledoc """
  Helpers for MPM (Merchant Presented Mode)
  """

  def validate_payload(payload) do

    payload_format_indicator = String.slice(payload, 0, 6)

    payload_length = String.length(payload)
    without_checksum = String.slice(payload, 0, payload_length - 4)
    payload_checksum = String.slice(payload, payload_length - 4, 4)
    expected_checksum = Exemvi.CRC.checksum_hex(without_checksum)

    all_ok = payload_format_indicator == "000201"
    all_ok = all_ok and payload_checksum == expected_checksum

    if all_ok do
      {:ok, nil}
    else
      {:error, Exemvi.Error.invalid_payload}
    end
  end

  def parse(payload) do
    case parse_rest(payload, []) do
      {:error, reason} -> {:error, reason}
      {:ok, tlvs} -> {:ok, tlvs}
    end
  end

  def validate(tlvs, :all) do
    reasons = []

    {_, mandatory_reasons} = validate(tlvs, :mandatory)
    reasons = reasons ++ (mandatory_reasons || [])

    {_, spec_reasons} = validate(tlvs, :spec)
    reasons = reasons ++ (spec_reasons || [])

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  def validate(tlvs, :mandatory) do
    mandatories =
      Exemvi.MPM.DataObject.specifications()
      |> Enum.filter(fn x -> x[:must] end)
      |> Enum.map(fn x -> Map.get(x, :atom) end)

    tlv_data_objects = Enum.map(
      tlvs,
      fn x -> x.data_object end)

    reasons = Enum.reduce(
      mandatories,
      [],
      fn mandatory_atom, reason_acc -> data_object_exists(tlv_data_objects, mandatory_atom, reason_acc) end)

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  def validate(tlvs, :spec) do
    validate_specs_rest(tlvs, [])
  end

  defp parse_rest("", tlvs) do
    {:ok, tlvs}
  end

  defp parse_rest(payload, tlvs) do

    data_length_raw = payload |> String.slice(2, 2)
    data_length = case Integer.parse(data_length_raw) do
      {i, ""} -> i
      _ -> 0
    end

    data_object = payload |> String.slice(0, 2)
    data_object_atom = Exemvi.MPM.DataObject.code_atoms()[data_object]

    cond do
      data_object_atom == nil -> {:error, Exemvi.Error.invalid_data_object}
      data_length == 0 -> {:error, Exemvi.Error.invalid_data_length}
      true ->
        data_value = String.slice(payload, 4, data_length)
        tlvs = tlvs ++ [%Exemvi.TLV{data_object: data_object, data_value: data_value}]
        rest = String.slice(payload, (4 + data_length)..-1)
        parse_rest(rest, tlvs)
    end
  end

  defp data_object_exists(data_object_atoms, atom, reasons) do
    if Enum.member?(data_object_atoms, atom) do
      reasons
    else
      [Exemvi.Error.missing_data_object(atom) | reasons]
    end
  end

  defp validate_specs_rest([], reasons) do
    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp validate_specs_rest(tlvs, reasons) do
    [tlv | tlv_rest] = tlvs

    reasons = case validate_tlv(tlv) do
      {:error, invalid_reason} -> reasons ++ invalid_reason
      _ -> reasons
    end

    validate_specs_rest(tlv_rest, reasons)
  end

  defp validate_tlv(tlv) do
    data_object_atom = Exemvi.MPM.DataObject.code_atoms()[tlv.data_object]
    spec = Enum.find(
      Exemvi.MPM.DataObject.specifications(),
      fn x -> Map.get(x, :atom) == data_object_atom end)

    actual_len = String.length(tlv.data_value)
    len_is_ok = actual_len >= spec[:min_len] and actual_len <= spec[:max_len]

    format_is_ok = case spec[:regex] do
      nil -> true
      _ -> String.match?(tlv.data_value, spec[:regex])
    end

    if len_is_ok and format_is_ok do
      {:ok, nil}
    else
      {:error, Exemvi.Error.invalid_data_object(tlv.data_object)}
    end
  end
end

defmodule Exemvi.QR.M do

  alias Exemvi.QR.M.DataObject, as: DO

  @moduledoc """
  Helpers for MPM (Merchant Presented Mode)
  """

  def validate_qr(qr) do

    qr_format_indicator = String.slice(qr, 0, 6)

    qr_length = String.length(qr)
    without_checksum = String.slice(qr, 0, qr_length - 4)
    qr_checksum = String.slice(qr, qr_length - 4, 4)
    expected_checksum = Exemvi.CRC.checksum_hex(without_checksum)

    all_ok = qr_format_indicator == "000201"
    all_ok = all_ok and qr_checksum == expected_checksum

    if all_ok do
      {:ok, nil}
    else
      {:error, Exemvi.Error.invalid_qr}
    end
  end

  def parse_to_tlvs(qr) do
    case parse_to_tlvs_rest(qr, []) do
      {:error, reason} -> {:error, reason}
      {:ok, tlvs} -> {:ok, tlvs}
    end
  end

  def validate_tlvs(tlvs) do
    reasons = []

    {_, mandatory_reasons} = validate_tlvs(tlvs, :mandatory)
    reasons = reasons ++ (mandatory_reasons || [])

    {_, data_value_reasons} = validate_tlvs(tlvs, :data_value)
    reasons = reasons ++ (data_value_reasons || [])

    {_, orphaned_reasons} = validate_tlvs(tlvs, :orphaned)
    reasons = reasons ++ (orphaned_reasons || [])

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp parse_to_tlvs_rest("", tlvs) do
    {:ok, tlvs}
  end

  defp parse_to_tlvs_rest(qr, tlvs) do

    data_length_raw = qr |> String.slice(2, 2)
    data_length = case Integer.parse(data_length_raw) do
      {i, ""} -> i
      _ -> 0
    end

    data_object = qr |> String.slice(0, 2)
    data_object_atom = DO.code_atoms()[data_object]

    cond do
      data_object_atom == nil -> {:error, Exemvi.Error.invalid_data_object}
      data_length == 0 -> {:error, Exemvi.Error.invalid_data_length}
      true ->
        data_value = String.slice(qr, 4, data_length)
        tlvs = tlvs ++ [%Exemvi.TLV{data_object: data_object, data_value: data_value}]
        rest = String.slice(qr, (4 + data_length)..-1)
        parse_to_tlvs_rest(rest, tlvs)
    end
  end

  defp validate_tlvs(tlvs, :mandatory) do
    mandatories =
      DO.specifications()
      |> Enum.filter(fn x -> x[:must] end)
      |> Enum.map(fn x -> x[:atom] end)

    tlv_data_objects = Enum.map(tlvs, fn x -> DO.code_atoms()[x.data_object] end)

    data_object_exists = fn all_atoms, atom_to_check, reasons ->
      if Enum.member?(all_atoms, atom_to_check) do
        reasons
      else
        [Exemvi.Error.missing_data_object(atom_to_check) | reasons]
      end
    end

    reasons = Enum.reduce(
      mandatories,
      [],
      fn mandatory_atom, reason_acc -> data_object_exists.(tlv_data_objects, mandatory_atom, reason_acc) end)

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp validate_tlvs(tlvs, :data_value) do
    validate_tlvs_rest(tlvs, :data_value, [])
  end

  defp validate_tlvs(tlvs, :orphaned) do

    tlv_atoms = Enum.map(
      tlvs,
      fn x -> DO.code_atoms[x.data_object] end)

    specs_with_parent = Enum.filter(
      DO.specifications(),
      fn x -> x[:parent] != nil end)

    specs_in_tlvs = Enum.filter(
      specs_with_parent,
      fn x -> Enum.member?(tlv_atoms, x[:atom]) end)

    orphaned_atoms =
      specs_in_tlvs
      |> Enum.filter(fn x -> not Enum.member?(tlv_atoms, x[:parent]) end)
      |> Enum.map(fn x -> x[:atom] end)

    if Enum.count(orphaned_atoms) == 0 do
      {:ok, nil}
    else
      reasons = Enum.map(orphaned_atoms, fn x -> Exemvi.Error.orphaned_data_object(x) end)
      {:error, reasons}
    end
  end

  defp validate_tlvs_rest([], :data_value, reasons) do
    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp validate_tlvs_rest(tlvs, :data_value, reasons) do
    [tlv | tlv_rest] = tlvs

    reasons = case validate_data_value(tlv) do
      {:error, invalid_reason} -> reasons ++ [invalid_reason]
      _ -> reasons
    end

    validate_tlvs_rest(tlv_rest, :data_value, reasons)
  end

  defp validate_data_value(tlv) do
    data_object_atom = DO.code_atoms()[tlv.data_object]
    spec = Enum.find(
      DO.specifications(),
      fn x -> x[:atom] == data_object_atom end)

    actual_len = String.length(tlv.data_value)
    len_is_ok = actual_len >= spec[:min_len] and actual_len <= spec[:max_len]

    format_is_ok = case spec[:regex] do
      nil -> true
      _ -> String.match?(tlv.data_value, spec[:regex])
    end

    if len_is_ok and format_is_ok do
      {:ok, nil}
    else
      data_object_atom = DO.code_atoms()[tlv.data_object]
      {:error, Exemvi.Error.invalid_data_object(data_object_atom)}
    end
  end
end

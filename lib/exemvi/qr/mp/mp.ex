defmodule Exemvi.QR.MP do

  alias DO, as: DO

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

  def parse_to_data_objects(qr) do
    case parse_to_data_objects_rest(qr, []) do
      {:error, reason} -> {:error, reason}
      {:ok, data_objects} -> {:ok, data_objects}
    end
  end

  def validate_data_objects(data_objects) do
    reasons = []

    {_, mandatory_reasons} = validate_data_objects(data_objects, :mandatory)
    reasons = reasons ++ (mandatory_reasons || [])

    {_, object_value_reasons} = validate_data_objects(data_objects, :object_value)
    reasons = reasons ++ (object_value_reasons || [])

    {_, orphaned_reasons} = validate_data_objects(data_objects, :orphaned)
    reasons = reasons ++ (orphaned_reasons || [])

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp parse_to_data_objects_rest("", data_objects) do
    {:ok, data_objects}
  end

  defp parse_to_data_objects_rest(qr, data_objects) do

    data_length_raw = qr |> String.slice(2, 2)
    data_length = case Integer.parse(data_length_raw) do
      {i, ""} -> i
      _ -> 0
    end

    object_id = qr |> String.slice(0, 2)
    object_id_atom = DO.root_atoms()[object_id]

    cond do
      object_id_atom == nil -> {:error, Exemvi.Error.invalid_object_id}
      data_length == 0 -> {:error, Exemvi.Error.invalid_data_length}
      true ->
        object_value = String.slice(qr, 4, data_length)
        data_objects = data_objects ++ [%DO{id: object_id, value: object_value}]
        rest = String.slice(qr, (4 + data_length)..-1)
        parse_to_data_objects_rest(rest, data_objects)
    end
  end

  defp validate_data_objects(data_objects, :mandatory) do
    mandatory_ids =
      DO.root_specs()
      |> Enum.filter(fn x -> x[:must] end)
      |> Enum.map(fn x -> x[:atom] end)

    data_object_ids = Enum.map(data_objects, fn x -> DO.root_atoms()[x.id] end)

    id_exists = fn all_atoms, atom_to_check, reasons ->
      if Enum.member?(all_atoms, atom_to_check) do
        reasons
      else
        [Exemvi.Error.missing_object_id(atom_to_check) | reasons]
      end
    end

    reasons = Enum.reduce(
      mandatory_ids,
      [],
      fn mandatory_id, reason_acc -> id_exists.(data_object_ids, mandatory_id, reason_acc) end)

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp validate_data_objects(data_objects, :object_value) do
    validate_data_objects_rest(data_objects, :object_value, [])
  end

  defp validate_data_objects(data_objects, :orphaned) do

    data_object_ids = Enum.map(
      data_objects,
      fn x -> DO.root_atoms[x.id] end)

    specs_with_parent = Enum.filter(
      DO.root_specs(),
      fn x -> x[:parent] != nil end)

    ids_with_parents = Enum.filter(
      specs_with_parent,
      fn x -> Enum.member?(data_object_ids, x[:atom]) end)

    orphaned_atoms =
      ids_with_parents
      |> Enum.filter(fn x -> not Enum.member?(data_object_ids, x[:parent]) end)
      |> Enum.map(fn x -> x[:atom] end)

    if Enum.count(orphaned_atoms) == 0 do
      {:ok, nil}
    else
      reasons = Enum.map(orphaned_atoms, fn x -> Exemvi.Error.orphaned_data_object(x) end)
      {:error, reasons}
    end
  end

  defp validate_data_objects_rest([], :object_value, reasons) do
    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp validate_data_objects_rest(data_objects, :object_value, reasons) do
    [data_object | data_object_rest] = data_objects

    reasons = case validate_object_value(data_object) do
      {:error, invalid_reason} -> reasons ++ [invalid_reason]
      _ -> reasons
    end

    validate_data_objects_rest(data_object_rest, :object_value, reasons)
  end

  defp validate_object_value(data_object) do
    data_object_atom = DO.root_atoms()[data_object.id]
    spec = Enum.find(
      DO.root_specs(),
      fn x -> x[:atom] == data_object_atom end)

    actual_len = String.length(data_object.value)
    len_is_ok = actual_len >= spec[:min_len] and actual_len <= spec[:max_len]

    format_is_ok = case spec[:regex] do
      nil -> true
      _ -> String.match?(data_object.value, spec[:regex])
    end

    if len_is_ok and format_is_ok do
      {:ok, nil}
    else
      data_object_atom = DO.root_atoms()[data_object.id]
      {:error, Exemvi.Error.invalid_object_value(data_object_atom)}
    end
  end
end

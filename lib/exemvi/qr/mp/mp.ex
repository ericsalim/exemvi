defmodule Exemvi.QR.MP do

  alias Exemvi.QR.MP.Object, as: MPO

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

  def parse_to_objects(qr) do
    case parse_to_objects_rest(qr, []) do
      {:error, reason} -> {:error, reason}
      {:ok, objects} -> {:ok, objects}
    end
  end

  def validate_objects(objects) do
    reasons = []

    {_, mandatory_reasons} = validate_objects(objects, :mandatory)
    reasons = reasons ++ (mandatory_reasons || [])

    {_, value_reasons} = validate_objects(objects, :object_value)
    reasons = reasons ++ (value_reasons || [])

    {_, orphaned_reasons} = validate_objects(objects, :orphaned)
    reasons = reasons ++ (orphaned_reasons || [])

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp parse_to_objects_rest("", objects) do
    {:ok, objects}
  end

  defp parse_to_objects_rest(qr, objects) do

    value_length_raw = qr |> String.slice(2, 2)
    value_length = case Integer.parse(value_length_raw) do
      {i, ""} -> i
      _ -> 0
    end

    id_raw = qr |> String.slice(0, 2)
    id_atom = MPO.root_id_atoms()[id_raw]

    cond do
      id_atom == nil -> {:error, Exemvi.Error.invalid_object_id}
      value_length == 0 -> {:error, Exemvi.Error.invalid_value_length}
      true ->
        value = String.slice(qr, 4, value_length)
        objects = objects ++ [%MPO{id: id_raw, value: value}]
        rest = String.slice(qr, (4 + value_length)..-1)
        parse_to_objects_rest(rest, objects)
    end
  end

  defp validate_objects(objects, :mandatory) do
    mandatory_ids =
      MPO.root_specs()
      |> Enum.filter(fn {_, v} -> v[:must] end)
      |> Enum.map(fn {k, _} -> k end)

    supplied_ids = Enum.map(objects, fn x -> MPO.root_id_atoms()[x.id] end)

    id_exists = fn all_ids, id_to_check, reasons ->
      if Enum.member?(all_ids, id_to_check) do
        reasons
      else
        [Exemvi.Error.missing_object_id(id_to_check) | reasons]
      end
    end

    reasons = Enum.reduce(
      mandatory_ids,
      [],
      fn mandatory_id, reason_acc -> id_exists.(supplied_ids, mandatory_id, reason_acc) end)

    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp validate_objects(objects, :object_value) do
    validate_objects_rest(objects, :object_value, [])
  end

  defp validate_objects(objects, :orphaned) do

    supplied_ids = Enum.map(
      objects,
      fn x -> MPO.root_id_atoms[x.id] end)

    spec_child_ids =
      MPO.root_specs()
      |> Enum.filter(fn {_, v} -> v[:parent] != nil end)
      |> Enum.map(fn {k, _} -> k end)

    supplied_child_ids =
      spec_child_ids
      |> Enum.filter(fn x -> Enum.member?(supplied_ids, x) end)

    orphaned_ids =
      supplied_child_ids
      |> Enum.filter(fn x -> not Enum.member?(supplied_ids, MPO.root_specs[x][:parent]) end)

    if Enum.count(orphaned_ids) == 0 do
      {:ok, nil}
    else
      reasons = Enum.map(orphaned_ids, fn x -> Exemvi.Error.orphaned_object(x) end)
      {:error, reasons}
    end
  end

  defp validate_objects_rest([], :object_value, reasons) do
    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp validate_objects_rest(objects, :object_value, reasons) do
    [object | object_rest] = objects

    reasons = case validate_object_value(object) do
      {:error, invalid_reason} -> reasons ++ [invalid_reason]
      _ -> reasons
    end

    validate_objects_rest(object_rest, :object_value, reasons)
  end

  defp validate_object_value(object) do
    id_atom = MPO.root_id_atoms()[object.id]
    spec = MPO.root_specs()[id_atom]

    actual_len = String.length(object.value)
    len_is_ok = actual_len >= spec[:min_len] and actual_len <= spec[:max_len]

    format_is_ok = case spec[:regex] do
      nil -> true
      _ -> String.match?(object.value, spec[:regex])
    end

    if len_is_ok and format_is_ok do
      {:ok, nil}
    else
      {:error, Exemvi.Error.invalid_object_value(id_atom)}
    end
  end
end

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
    case parse_to_objects_rest(:root, qr, []) do
      {:ok, objects} -> {:ok, objects}
      {:error, reason} -> {:error, reason}
    end
  end

  def validate_objects(objects) do
    reasons = validate_all_objects_rest(:root, objects, [])
    if Enum.count(reasons) == 0 do
      {:ok, nil}
    else
      {:error, reasons}
    end
  end

  defp parse_to_objects_rest(_template, "", objects) do
    {:ok, objects}
  end

  defp parse_to_objects_rest(template, qr_rest, objects) do

    id_raw = qr_rest |> String.slice(0, 2)
    id_atom = MPO.id_atoms(template)[id_raw]

    value_length_raw = qr_rest |> String.slice(2, 2)
    value_length = case Integer.parse(value_length_raw) do
      {i, ""} -> i
      _ -> 0
    end

    cond do
      id_atom == nil -> {:error, Exemvi.Error.invalid_object_id}
      value_length == 0 -> {:error, Exemvi.Error.invalid_value_length}
      true ->
        value = String.slice(qr_rest, 4, value_length)
        qr_rest_next = String.slice(qr_rest, (4 + value_length)..-1)

        is_template = MPO.specs(template)[id_atom][:is_template]
        if is_template do
            case parse_to_objects_rest(id_atom, value, []) do
              {:ok, inner_objects} ->
                object = %MPO{id: id_raw, objects: inner_objects}
                objects = objects ++ [object]
                parse_to_objects_rest(template, qr_rest_next, objects)
              {:error, reasons} -> {:error, reasons}
            end
        else
          object = %MPO{id: id_raw, value: value}
          objects = objects ++ [object]
          parse_to_objects_rest(template, qr_rest_next, objects)
        end
    end
  end

  defp validate_all_objects_rest(template, all_objects, reasons) do
    mandatory_reasons = validate_objects_exist(template, all_objects)
    reasons = reasons ++ mandatory_reasons

    orphaned_reasons = validate_objects_have_parents(template, all_objects)
    reasons = reasons ++ orphaned_reasons

    object_reasons = validate_object_rest(template, all_objects, reasons)
    reasons ++ object_reasons
  end

  defp validate_objects_exist(template, all_objects) do
    mandatory_ids =
      MPO.specs(template)
      |> Enum.filter(fn {_, v} -> v[:must] end)
      |> Enum.map(fn {k, _} -> k end)

    supplied_ids = Enum.map(all_objects, fn x -> MPO.id_atoms(template)[x.id] end)

    id_exists = fn all_ids, id_to_check, reasons ->
      if Enum.member?(all_ids, id_to_check) do
        reasons
      else
        reasons ++ [Exemvi.Error.missing_object_id(id_to_check)]
      end
    end

    reasons = Enum.reduce(
      mandatory_ids,
      [],
      fn mandatory_id, reason_acc -> id_exists.(supplied_ids, mandatory_id, reason_acc) end)

    if Enum.count(reasons) == 0 do
      []
    else
      reasons
    end
  end

  defp validate_objects_have_parents(template, all_objects) do
    supplied_ids = Enum.map(
      all_objects,
      fn x -> MPO.id_atoms(template)[x.id] end)

    spec_child_ids =
      MPO.specs(template)
      |> Enum.filter(fn {_, v} -> v[:parent] != nil end)
      |> Enum.map(fn {k, _} -> k end)

    supplied_child_ids =
      spec_child_ids
      |> Enum.filter(fn x -> Enum.member?(supplied_ids, x) end)

    orphaned_ids =
      supplied_child_ids
      |> Enum.filter(fn x -> not Enum.member?(supplied_ids, MPO.specs(template)[x][:parent]) end)

    if Enum.count(orphaned_ids) == 0 do
      []
    else
      Enum.map(orphaned_ids, fn x -> Exemvi.Error.orphaned_object(x) end)
    end
  end

  defp validate_object_rest(_template, [], reasons) do
    reasons
  end

  defp validate_object_rest(template, objects_rest, reasons) do

    [object | objects_rest_next] = objects_rest

    value_reasons = validate_object_value(template, object)
    reasons = reasons ++ value_reasons

    template_reasons = cond do
      Enum.count(value_reasons) == 0 and object.objects != nil ->
        id_atom = MPO.id_atoms(template)[object.id]
        validate_all_objects_rest(id_atom, object.objects, reasons)
      true -> []
    end
    reasons = reasons ++ template_reasons

    validate_object_rest(template, objects_rest_next, reasons)
  end

  defp validate_object_value(template, object) do
    id_atom = MPO.id_atoms(template)[object.id]
    spec = MPO.specs(template)[id_atom]

    if Enum.count(object.objects || []) > 0 do
      []
    else
      object_value = object.value || ""

      actual_len = String.length(object_value)
      len_is_ok = actual_len >= spec[:min_len] and actual_len <= spec[:max_len]

      format_is_ok = case spec[:regex] do
        nil -> true
        _ -> String.match?(object_value, spec[:regex])
      end

      if len_is_ok and format_is_ok do
        []
      else
        [Exemvi.Error.invalid_object_value(id_atom)]
      end
    end
  end
end

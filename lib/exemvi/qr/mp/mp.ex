defmodule Exemvi.QR.MP do
  alias Exemvi.QR.MP.Object, as: MPO

  @moduledoc """
  This module contains core functions for Merchant-Presented Mode QR Code
  """

  @doc """
  Validate whole QR Code

  Returns either:
  - `{:ok, qr_code}` where `qr_code` is the QR Code orginally supplied to the function
  - `{:error, reasons}` where `reasons` is a list of validation error reasons as atoms
  """

  def validate_qr(qr) when is_binary(qr) do
    with :ok <- validate_format(qr),
         :ok <- validate_checksum(qr) do
      {:ok, qr}
    else
      _ -> {:error, [Exemvi.Error.invalid_qr()]}
    end
  end

  def validate_qr(_), do: {:error, [Exemvi.Error.invalid_qr()]}

  defp validate_format("000201" <> _), do: :ok
  defp validate_format(_), do: :invalid_format

  defp validate_checksum(qr) do
    qr_length = String.length(qr)
    without_checksum = String.slice(qr, 0, qr_length - 4)
    qr_checksum = String.slice(qr, qr_length - 4, 4)
    expected_checksum = Exemvi.CRC.checksum_hex(without_checksum)

    case qr_checksum == expected_checksum do
      true -> :ok
      _ -> :checksum_failed
    end
  end

  def parse_to_objects({:ok, qr}) do
    parse_to_objects(qr)
  end

  def parse_to_objects({:error, reasons}) do
    {:error, reasons}
  end

  @doc """
  Parse QR Code into data objects

  Returns either:
  - `{:ok, objects}` where `objects` is a list of `Exemvi.MP.Object` structs
  - `{:error, reasons}` where `reasons` is a list of error reasons as atoms
  """
  def parse_to_objects(qr) do
    case parse_to_objects_rest(:root, qr, []) do
      {:ok, objects} -> {:ok, objects}
      {:error, reasons} -> {:error, reasons}
    end
  end

  def validate_objects({:ok, objects}) do
    validate_objects(objects)
  end

  def validate_objects({:error, reasons}) do
    {:error, reasons}
  end

  @doc """
  Validate data objects

  Returns either:
  - `{:ok, objects}` where `objects` is the objects originally supplied to the function
  - `{:error, reasons}` where `reasons` is a list of validation error reasons as atoms
  """
  def validate_objects(objects) do
    reasons = validate_all_objects_rest(:root, objects, [])

    if Enum.count(reasons) == 0 do
      {:ok, objects}
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

    value_length =
      case Integer.parse(value_length_raw) do
        {i, ""} when i > 0 -> i
        _ -> 0
      end

    cond do
      id_atom == nil ->
        {:error, [Exemvi.Error.invalid_object_id()]}

      value_length == 0 ->
        {:error, [Exemvi.Error.invalid_value_length()]}

      true ->
        value = String.slice(qr_rest, 4, value_length)
        qr_rest_next = String.slice(qr_rest, (4 + value_length)..-1//1)

        is_template = MPO.specs(template)[id_atom][:is_template]

        maybe_object =
          case is_template do
            false ->
              {:ok, %MPO{id: id_raw, value: value}}

            true ->
              case parse_to_objects_rest(id_atom, value, []) do
                {:ok, inner_objects} ->
                  {:ok, %MPO{id: id_raw, objects: inner_objects}}

                {:error, reasons} ->
                  {:error, reasons}
              end
          end

        case maybe_object do
          {:error, reasons} ->
            {:error, reasons}

          {:ok, object} ->
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
      |> Enum.filter(fn {_, v} -> v[:must] == true and v[:must_alias] == nil end)
      |> Enum.map(fn {k, _} -> k end)

    supplied_ids =
      all_objects
      |> Enum.map(fn x -> MPO.id_atoms(template)[x.id] end)
      |> Enum.map(fn x -> MPO.specs(template)[x][:must_alias] || x end)

    id_exists = fn all_ids, id_to_check, reasons ->
      if Enum.member?(all_ids, id_to_check) do
        reasons
      else
        reasons ++ [Exemvi.Error.missing_object_id(id_to_check)]
      end
    end

    reasons =
      Enum.reduce(
        mandatory_ids,
        [],
        fn mandatory_id, reason_acc -> id_exists.(supplied_ids, mandatory_id, reason_acc) end
      )

    if Enum.count(reasons) == 0 do
      []
    else
      reasons
    end
  end

  defp validate_objects_have_parents(template, all_objects) do
    supplied_ids =
      Enum.map(
        all_objects,
        fn x -> MPO.id_atoms(template)[x.id] end
      )

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

    template_reasons =
      cond do
        Enum.count(value_reasons) == 0 and object.objects != nil ->
          id_atom = MPO.id_atoms(template)[object.id]
          validate_all_objects_rest(id_atom, object.objects, reasons)

        true ->
          []
      end

    reasons = reasons ++ template_reasons

    validate_object_rest(template, objects_rest_next, reasons)
  end

  defp validate_object_value(template, object) do
    id_atom = MPO.id_atoms(template)[object.id]
    spec = MPO.specs(template)[id_atom]

    if spec[:is_template] do
      []
    else
      object_value = object.value || ""

      actual_len = String.length(object_value)
      len_is_ok = actual_len >= spec[:min_len] and actual_len <= spec[:max_len]

      format_is_ok =
        case spec[:regex] do
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

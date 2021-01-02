defmodule MPMTest do
  use ExUnit.Case

  @official_sample "00020101021229300012D156000000000510A93FO3230Q31280012D15600000001030812345678520441115802CN5914BEST TRANSPORT6007BEIJING64200002ZH0104最佳运输0202北京540523.7253031565502016233030412340603***0708A60086670902ME91320016A0112233449988770708123456786304A13A"
  @official_tlv [
    %Exemvi.TLV{data_object: "00", data_value: "01"},
    %Exemvi.TLV{data_object: "01", data_value: "12"},
    %Exemvi.TLV{data_object: "29", data_value: "0012D156000000000510A93FO3230Q"},
    %Exemvi.TLV{data_object: "31", data_value: "0012D15600000001030812345678"},
    %Exemvi.TLV{data_object: "52", data_value: "4111"},
    %Exemvi.TLV{data_object: "58", data_value: "CN"},
    %Exemvi.TLV{data_object: "59", data_value: "BEST TRANSPORT"},
    %Exemvi.TLV{data_object: "60", data_value: "BEIJING"},
    %Exemvi.TLV{data_object: "64", data_value: "0002ZH0104最佳运输0202北京"},
    %Exemvi.TLV{data_object: "54", data_value: "23.72"},
    %Exemvi.TLV{data_object: "53", data_value: "156"},
    %Exemvi.TLV{data_object: "55", data_value: "01"},
    %Exemvi.TLV{data_object: "62", data_value: "030412340603***0708A60086670902ME"},
    %Exemvi.TLV{data_object: "91", data_value: "0016A011223344998877070812345678"},
    %Exemvi.TLV{data_object: "63", data_value: "A13A"}
  ]

  test "entire payload: successful" do
    with {:ok, tlvs} <- Exemvi.MPM.parse(@official_sample)
    do
      # Check only some fields

      # Check payload format indicator
      pfi = Enum.at(tlvs, 0)
      assert pfi.data_object == "00"
      assert pfi.data_value == "01"

      # Check merchant information
      merchant_info = Enum.at(tlvs, 8)
      assert merchant_info.data_object == "64"
      assert merchant_info.data_value == "0002ZH0104最佳运输0202北京"

      assert false, "TODO Additional data 62"

      # Check checksum
      checksum = Enum.at(tlvs, 14)
      assert checksum.data_object == "63"
      assert checksum.data_value == "A13A"
    else
      _ -> assert false, "Parsing failed"
    end
  end

  test "entire payload: data length is not numeric" do
    payload = "00A201"
    {result, reason} = Exemvi.MPM.parse(payload)
    assert result == :error
    assert reason == :invalid_data_length
  end

  test "entire payload: does not start with payload format indicator" do
    wrong_payload = @official_sample <> "01"

    {:error, reason} = Exemvi.MPM.validate_payload(wrong_payload)
    assert reason == Exemvi.Error.invalid_payload
  end

  test "entire payload: checksum is invalid" do
    start_of_checksum = String.length(@official_sample) - 4
    without_checksum = String.slice(@official_sample, 0, start_of_checksum)
    wrong_checksum = "ABCD"
    wrong_payload = without_checksum <> wrong_checksum

    {:error, reason} = Exemvi.MPM.validate_payload(wrong_payload)
    assert reason == Exemvi.Error.invalid_payload
  end

  test "official tlv sample is valid" do
    test_data = @official_tlv

    {result, _} = Exemvi.MPM.validate_tlvs(test_data)

    assert result == :ok
  end

  test "payload format indicator is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.code_atoms()[x.data_object] != :payload_format_indicator end)
    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:payload_format_indicator))
  end

  test "payload format indicator is not 01" do
    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:payload_format_indicator)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "02"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:payload_format_indicator))
  end

  test "point of initiation value is not 11 or 12" do
    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:point_of_initiation_method)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "10"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:point_of_initiation_method))

      test_data = List.replace_at(
        test_data,
        Enum.find_index(test_data, fn x -> x.data_object == code end),
        %Exemvi.TLV{data_object: code, data_value: "13"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:point_of_initiation_method))
  end

  test "merchant account information is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.code_atoms()[x.data_object] != :merchant_account_information end)
    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_account_information))
  end

  test "merchant category code is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.code_atoms()[x.data_object] != :merchant_category_code end)
    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_category_code))
  end

  test "merchant category code value is not 4 integer digits" do

    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:merchant_category_code)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "12AB"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:merchant_category_code))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "123"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:merchant_category_code))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "12345"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:merchant_category_code))
  end

  test "transaction currency is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.code_atoms()[x.data_object] != :transaction_currency end)
    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:transaction_currency))
  end

  test "transaction currency value is not 3 integer digits" do
    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:transaction_currency)

    test_data = List.insert_at(
      test_data,
      0,
      %Exemvi.TLV{data_object: code, data_value: "12AB"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:transaction_currency))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "12"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:transaction_currency))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "1234"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:transaction_currency))
  end

  test "transaction amount value is longer than 13 decimal digits" do

    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:transaction_amount)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "12345678901234"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:transaction_amount))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "123456789012.4"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:transaction_amount))
  end

  test "convenience indicator is not 2 integer digits" do

    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:tip_or_convenience_indicator)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "1A"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:tip_or_convenience_indicator))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "1"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:tip_or_convenience_indicator))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "123"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:tip_or_convenience_indicator))
  end

  test "convenience fee fixed is orphaned" do
    test_data = @official_tlv

    convenience_code = Exemvi.MPM.DataObject.code_by_atom(:tip_or_convenience_indicator)

    test_data = List.delete_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == convenience_code end))

    test_data = List.insert_at(
      test_data,
      0,
      %Exemvi.TLV
      {
        data_object: Exemvi.MPM.DataObject.code_by_atom(:value_of_convenience_fee_fixed),
        data_value: "1"
      })

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.orphaned_data_object(:value_of_convenience_fee_fixed))
  end

  test "convenience fee fixed is longer than 13 decimal digits" do

    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:value_of_convenience_fee_fixed)

    test_data = List.insert_at(
      test_data,
      0,
      %Exemvi.TLV{data_object: code, data_value: "12345678901234"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:value_of_convenience_fee_fixed))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "123456789012.4"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:value_of_convenience_fee_fixed))
  end

  test "convenience fee percentage is orphaned" do
    test_data = @official_tlv

    convenience_code = Exemvi.MPM.DataObject.code_by_atom(:tip_or_convenience_indicator)

    test_data = List.delete_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == convenience_code end))

    test_data = List.insert_at(
      test_data,
      0,
      %Exemvi.TLV
      {
        data_object: Exemvi.MPM.DataObject.code_by_atom(:value_of_convenience_fee_percentage),
        data_value: "1"
      })

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.orphaned_data_object(:value_of_convenience_fee_percentage))
  end

  test "convenience fee percentage is longer than 5 decimal digits" do
    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:value_of_convenience_fee_percentage)

    test_data = List.insert_at(
      test_data,
      0,
      %Exemvi.TLV{data_object: code, data_value: "123456"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:value_of_convenience_fee_percentage))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "1234.6"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:value_of_convenience_fee_percentage))
  end

  test "country code is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.code_atoms()[x.data_object] != :country_code end)
    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:country_code))
  end

  test "country code is not 2 chars" do

    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:country_code)

    test_data = List.insert_at(
      test_data,
      0,
      %Exemvi.TLV{data_object: code, data_value: "A"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:country_code))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "ABC"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:country_code))
  end

  test "merchant name is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.code_atoms()[x.data_object] != :merchant_name end)
    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_name))
  end

  test "merchant name is longer than 25 chars" do
    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:country_code)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:country_code))
  end

  test "merchant city is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.code_atoms()[x.data_object] != :merchant_city end)
    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_city))
  end

  test "merchant city is longer than 15 chars" do
    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:merchant_city)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.data_object == code end),
      %Exemvi.TLV{data_object: code, data_value: "ABCDEFGHIJKLMNOP"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:merchant_city))
  end

  test "postal code is longer than 10 chars" do
    test_data = @official_tlv

    code = Exemvi.MPM.DataObject.code_by_atom(:postal_code)

    test_data = List.insert_at(
      test_data,
      0,
      %Exemvi.TLV{data_object: code, data_value: "ABCDEFGHIJK"})

    {:error, reasons} = Exemvi.MPM.validate_tlvs(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_data_object(:postal_code))
  end

  test "additional data template is parsed into tlv" do
    assert false, "TODO"
  end
end

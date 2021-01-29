defmodule MPMTest do
  use ExUnit.Case

  alias Exemvi.QR.MP, as: MP
  alias Exemvi.QR.MP.Object, as: MPO

  @official_sample "00020101021229300012D156000000000510A93FO3230Q31280012D15600000001030812345678520441115802CN5914BEST TRANSPORT6007BEIJING64200002ZH0104最佳运输0202北京540523.7253031565502016233030412340603***0708A60086670902ME91320016A0112233449988770708123456786304A13A"
  @official_objects [
    %MPO{id: "00", value: "01"},
    %MPO{id: "01", value: "12"},
    %MPO{id: "29", value: "0012D156000000000510A93FO3230Q"},
    %MPO{id: "31", value: "0012D15600000001030812345678"},
    %MPO{id: "52", value: "4111"},
    %MPO{id: "58", value: "CN"},
    %MPO{id: "59", value: "BEST TRANSPORT"},
    %MPO{id: "60", value: "BEIJING"},
    %MPO{id: "64", value: "0002ZH0104最佳运输0202北京"},
    %MPO{id: "54", value: "23.72"},
    %MPO{id: "53", value: "156"},
    %MPO{id: "55", value: "01"},
    %MPO{
      id: "62",
      value: nil,
      objects: [
        %MPO{id: "03", objects: nil, value: "1234"},
        %MPO{id: "06", objects: nil, value: "***"},
        %MPO{id: "07", objects: nil, value: "A6008667"},
        %MPO{id: "09", objects: nil, value: "ME"}
      ]},
    %MPO{id: "91", value: "0016A011223344998877070812345678"},
    %MPO{id: "63", value: "A13A"}
  ]

  test "official sample qr parsing is successful" do
    with {:ok, objects} <- MP.parse_to_objects(@official_sample)
    do
      # Check only some fields

      # Check payload format indicator
      pfi = Enum.at(objects, 0)
      assert pfi.id == "00"
      assert pfi.value == "01"

      # Check merchant information
      merchant_info = Enum.at(objects, 8)
      assert merchant_info.id == "64"
      assert merchant_info.value == "0002ZH0104最佳运输0202北京"

      # Check checksum
      checksum = Enum.at(objects, 14)
      assert checksum.id == "63"
      assert checksum.value == "A13A"
    else
      _ -> assert false, "Parsing failed"
    end
  end

  test "qr data length is not numeric" do
    payload = "00A201"
    {result, reason} = MP.parse_to_objects(payload)
    assert result == :error
    assert reason == :invalid_value_length
  end

  test "qr does not start with payload format indicator" do
    wrong_payload = @official_sample <> "01"

    {:error, reason} = MP.validate_qr(wrong_payload)
    assert reason == Exemvi.Error.invalid_qr
  end

  test "qr checksum is invalid" do
    start_of_checksum = String.length(@official_sample) - 4
    without_checksum = String.slice(@official_sample, 0, start_of_checksum)
    wrong_checksum = "ABCD"
    wrong_payload = without_checksum <> wrong_checksum

    {:error, reason} = MP.validate_qr(wrong_payload)
    assert reason == Exemvi.Error.invalid_qr
  end

  test "official data object sample is valid" do
    test_data = @official_objects

    {result, _} = MP.validate_objects(test_data)

    assert result == :ok
  end

  test "payload format indicator is missing" do
    test_data = Enum.filter(
      @official_objects,
      fn x -> MPO.id_atoms(:root)[x.id] != :payload_format_indicator end)
    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_object_id(:payload_format_indicator))
  end

  test "payload format indicator is not 01" do
    test_data = @official_objects

    code = MPO.id_raw(:root, :payload_format_indicator)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "02"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:payload_format_indicator))
  end

  test "point of initiation value is not 11 or 12" do
    test_data = @official_objects

    code = MPO.id_raw(:root, :point_of_initiation_method)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "10"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:point_of_initiation_method))

      test_data = List.replace_at(
        test_data,
        Enum.find_index(test_data, fn x -> x.id == code end),
        %MPO{id: code, value: "13"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:point_of_initiation_method))
  end

  test "merchant account information is missing" do
    test_data = Enum.filter(
      @official_objects,
      fn x -> MPO.id_atoms(:root)[x.id] != :merchant_account_information end)
    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_object_id(:merchant_account_information))
  end

  test "merchant category code is missing" do
    test_data = Enum.filter(
      @official_objects,
      fn x -> MPO.id_atoms(:root)[x.id] != :merchant_category_code end)
    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_object_id(:merchant_category_code))
  end

  test "merchant category code value is not 4 integer digits" do

    test_data = @official_objects

    code = MPO.id_raw(:root, :merchant_category_code)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "12AB"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:merchant_category_code))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "123"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:merchant_category_code))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "12345"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:merchant_category_code))
  end

  test "transaction currency is missing" do
    test_data = Enum.filter(
      @official_objects,
      fn x -> MPO.id_atoms(:root)[x.id] != :transaction_currency end)
    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_object_id(:transaction_currency))
  end

  test "transaction currency value is not 3 integer digits" do
    test_data = @official_objects

    code = MPO.id_raw(:root, :transaction_currency)

    test_data = List.insert_at(
      test_data,
      0,
      %MPO{id: code, value: "12AB"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:transaction_currency))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "12"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:transaction_currency))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "1234"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:transaction_currency))
  end

  test "transaction amount value is longer than 13 decimal digits" do

    test_data = @official_objects

    code = MPO.id_raw(:root, :transaction_amount)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "12345678901234"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:transaction_amount))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "123456789012.4"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:transaction_amount))
  end

  test "convenience indicator is not 2 integer digits" do

    test_data = @official_objects

    code = MPO.id_raw(:root, :tip_or_convenience_indicator)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "1A"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:tip_or_convenience_indicator))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "1"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:tip_or_convenience_indicator))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "123"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:tip_or_convenience_indicator))
  end

  test "convenience fee fixed is orphaned" do
    test_data = @official_objects

    convenience_code = MPO.id_raw(:root, :tip_or_convenience_indicator)

    test_data = List.delete_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == convenience_code end))

    test_data = List.insert_at(
      test_data,
      0,
      %MPO
      {
        id: MPO.id_raw(:root, :value_of_convenience_fee_fixed),
        value: "1"
      })

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.orphaned_object(:value_of_convenience_fee_fixed))
  end

  test "convenience fee fixed is longer than 13 decimal digits" do

    test_data = @official_objects

    code = MPO.id_raw(:root, :value_of_convenience_fee_fixed)

    test_data = List.insert_at(
      test_data,
      0,
      %MPO{id: code, value: "12345678901234"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:value_of_convenience_fee_fixed))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "123456789012.4"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:value_of_convenience_fee_fixed))
  end

  test "convenience fee percentage is orphaned" do
    test_data = @official_objects

    convenience_code = MPO.id_raw(:root, :tip_or_convenience_indicator)

    test_data = List.delete_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == convenience_code end))

    test_data = List.insert_at(
      test_data,
      0,
      %MPO
      {
        id: MPO.id_raw(:root, :value_of_convenience_fee_percentage),
        value: "1"
      })

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.orphaned_object(:value_of_convenience_fee_percentage))
  end

  test "convenience fee percentage is longer than 5 decimal digits" do
    test_data = @official_objects

    code = MPO.id_raw(:root, :value_of_convenience_fee_percentage)

    test_data = List.insert_at(
      test_data,
      0,
      %MPO{id: code, value: "123456"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:value_of_convenience_fee_percentage))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "1234.6"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:value_of_convenience_fee_percentage))
  end

  test "country code is missing" do
    test_data = Enum.filter(
      @official_objects,
      fn x -> MPO.id_atoms(:root)[x.id] != :country_code end)
    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_object_id(:country_code))
  end

  test "country code is not 2 chars" do

    test_data = @official_objects

    code = MPO.id_raw(:root, :country_code)

    test_data = List.insert_at(
      test_data,
      0,
      %MPO{id: code, value: "A"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:country_code))

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "ABC"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:country_code))
  end

  test "merchant name is missing" do
    test_data = Enum.filter(
      @official_objects,
      fn x -> MPO.id_atoms(:root)[x.id] != :merchant_name end)
    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_object_id(:merchant_name))
  end

  test "merchant name is longer than 25 chars" do
    test_data = @official_objects

    code = MPO.id_raw(:root, :country_code)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:country_code))
  end

  test "merchant city is missing" do
    test_data = Enum.filter(
      @official_objects,
      fn x -> MPO.id_atoms(:root)[x.id] != :merchant_city end)
    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_object_id(:merchant_city))
  end

  test "merchant city is longer than 15 chars" do
    test_data = @official_objects

    code = MPO.id_raw(:root, :merchant_city)

    test_data = List.replace_at(
      test_data,
      Enum.find_index(test_data, fn x -> x.id == code end),
      %MPO{id: code, value: "ABCDEFGHIJKLMNOP"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:merchant_city))
  end

  test "postal code is longer than 10 chars" do
    test_data = @official_objects

    code = MPO.id_raw(:root, :postal_code)

    test_data = List.insert_at(
      test_data,
      0,
      %MPO{id: code, value: "ABCDEFGHIJK"})

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:postal_code))
  end

  test "additional data template is parsed into data objects" do
    with {:ok, objects} <- MP.parse_to_objects(@official_sample) do

      id_62_raw = MPO.id_raw(:root, :additional_data_field_template)
      object_62 = Enum.find(objects, fn x -> x.id == id_62_raw end)

      assert object_62 != nil
      assert object_62.objects != nil
      assert Enum.count(object_62.objects) == 4

      store_label = object_62.objects |> Enum.at(0)
      assert store_label.id == "03"
      assert store_label.value == "1234"

      customer_label = object_62.objects |> Enum.at(1)
      assert customer_label.id == "06"
      assert customer_label.value == "***"

      terminal_label = object_62.objects |> Enum.at(2)
      assert terminal_label.id == "07"
      assert terminal_label.value == "A6008667"

      additional_consumer_data_request = object_62.objects |> Enum.at(3)
      assert additional_consumer_data_request.id == "09"
      assert additional_consumer_data_request.value == "ME"
    else
      _ -> assert false, "Failed parsing additional data template"
    end
  end

  test "additional data bill number is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_01 = MPO.id_raw(:additional_data_field_template, :bill_number)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_01, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:bill_number))
  end

  test "additional data mobile number is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_02 = MPO.id_raw(:additional_data_field_template, :mobile_number)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_02, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:mobile_number))
  end

  test "additional data store label is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_03 = MPO.id_raw(:additional_data_field_template, :store_label)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_03, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:store_label))
  end

  test "additional data loyalty number is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_04 = MPO.id_raw(:additional_data_field_template, :loyalty_number)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_04, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:loyalty_number))
  end

  test "additional data reference label is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_05 = MPO.id_raw(:additional_data_field_template, :reference_label)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_05, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:reference_label))
  end

  test "additional data customer label is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_06 = MPO.id_raw(:additional_data_field_template, :customer_label)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_06, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:customer_label))
  end

  test "additional data terminal label is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_07 = MPO.id_raw(:additional_data_field_template, :terminal_label)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_07, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:terminal_label))
  end

  test "additional data purpose of transaction is longer than 25 chars" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_08 = MPO.id_raw(:additional_data_field_template, :purpose_of_transaction)

    test_data = [%MPO{id: code_62, objects: [%MPO{id: code_08, value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }] }]

    {:error, reasons} = MP.validate_objects(test_data)
    assert Enum.member?(
      reasons,
      Exemvi.Error.invalid_object_value(:purpose_of_transaction))
  end

  test "additional data consumer data request is invalid" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_09 = MPO.id_raw(:additional_data_field_template, :additional_consumer_data_request)

    test_data = [
      [%MPO{id: code_62, objects: [%MPO{id: code_09, value: "AAA" }] }],
      [%MPO{id: code_62, objects: [%MPO{id: code_09, value: "XYZ" }] }],
      [%MPO{id: code_62, objects: [%MPO{id: code_09, value: "AMEA"}] }]
    ]

    expected_error = Exemvi.Error.invalid_object_value(:additional_consumer_data_request)

    test_data
    |> Enum.map(fn x -> MP.validate_objects(x) end)
    |> Enum.map(fn {:error, reasons} -> Enum.member?(reasons, expected_error) end)
    |> Enum.each(fn x -> assert x end)
  end

  test "merchant information language template is parsed into data objects" do
    assert false, "TODO"
  end
end

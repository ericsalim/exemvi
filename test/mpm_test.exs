defmodule MPMTest do
  use ExUnit.Case

  alias Exemvi.QR.MP, as: MP
  alias Exemvi.QR.MP.Object, as: MPO

  @official_sample "00020101021229300012D156000000000510A93FO3230Q31280012D15600000001030812345678520441115802CN5914BEST TRANSPORT6007BEIJING64200002ZH0104最佳运输0202北京540523.7253031565502016233030412340603***0708A60086670902ME91320016A0112233449988770708123456786304A13A"
  @official_objects [
    %MPO{id: "00", value: "01"},
    %MPO{id: "01", value: "12"},
    %MPO{
      id: "29",
      objects: [
        %Exemvi.QR.MP.Object{id: "00", value: "D15600000000"},
        %Exemvi.QR.MP.Object{id: "05", value: "A93FO3230Q"}
      ]
    },
    %MPO{
      id: "31",
      objects: [
        %Exemvi.QR.MP.Object{id: "00", value: "D15600000001"},
        %Exemvi.QR.MP.Object{id: "03", value: "12345678"}
      ]
    },
    %MPO{id: "52", value: "4111"},
    %MPO{id: "58", value: "CN"},
    %MPO{id: "59", value: "BEST TRANSPORT"},
    %MPO{id: "60", value: "BEIJING"},
    %MPO{
      id: "64",
      objects: [
        %Exemvi.QR.MP.Object{id: "00", value: "ZH"},
        %Exemvi.QR.MP.Object{id: "01", value: "最佳运输"},
        %Exemvi.QR.MP.Object{id: "02", value: "北京"}
      ]
    },
    %MPO{id: "54", value: "23.72"},
    %MPO{id: "53", value: "156"},
    %MPO{id: "55", value: "01"},
    %MPO{
      id: "62",
      objects: [
        %MPO{id: "03", value: "1234"},
        %MPO{id: "06", value: "***"},
        %MPO{id: "07", value: "A6008667"},
        %MPO{id: "09", value: "ME"}
      ]
    },
    %MPO{id: "91", value: "0016A011223344998877070812345678"},
    %MPO{id: "63", value: "A13A"}
  ]

  defp assert_invalid_qr(qr) do
    {:error, reasons} = MP.validate_qr(qr)
    assert Enum.member?(reasons, Exemvi.Error.invalid_qr())
  end

  defp assert_invalid_object(data, [{type, reason}]) do
    {:error, reasons} = MP.validate_objects(data)

    expected_reason =
      case type do
        :invalid_value -> Exemvi.Error.invalid_object_value(reason)
        :missing_id -> Exemvi.Error.missing_object_id(reason)
        :orphaned -> Exemvi.Error.orphaned_object(reason)
      end

    assert Enum.member?(reasons, expected_reason)
  end

  test "basic usage of parsing and validation is successful" do
    {:ok, objects} =
      @official_sample
      |> MP.validate_qr()
      |> MP.parse_to_objects()
      |> MP.validate_objects()

    assert Enum.count(objects) > 0
  end

  test "official sample qr parsing is successful" do
    with {:ok, objects} <- MP.parse_to_objects(@official_sample) do
      # Check only some fields

      pfi = Enum.at(objects, 0)
      assert pfi.id == "00"
      assert pfi.value == "01"

      merchant_info = Enum.at(objects, 6)
      assert merchant_info.id == "59"
      assert merchant_info.value == "BEST TRANSPORT"

      merchant_info = Enum.at(objects, 9)
      assert merchant_info.id == "54"
      assert merchant_info.value == "23.72"

      checksum = Enum.at(objects, 14)
      assert checksum.id == "63"
      assert checksum.value == "A13A"
    else
      _ -> assert false, "Parsing failed"
    end
  end

  test "qr data length is not numeric" do
    payload = "00A201"
    {result, reasons} = MP.parse_to_objects(payload)
    assert result == :error
    assert Enum.member?(reasons, Exemvi.Error.invalid_value_length())
  end

  test "qr is too short" do
    for qr <- ["", "123", "          "] do
      assert_invalid_qr(qr)
    end
  end

  test "qr is blank" do
    assert_invalid_qr("          ")
  end

  test "qr does not start with payload format indicator" do
    wrong_payload = "01" <> @official_sample
    assert_invalid_qr(wrong_payload)
  end

  test "qr checksum is invalid" do
    start_of_checksum = String.length(@official_sample) - 4
    without_checksum = String.slice(@official_sample, 0, start_of_checksum)
    wrong_checksum = "ABCD"
    wrong_payload = without_checksum <> wrong_checksum

    assert_invalid_qr(wrong_payload)
  end

  test "official data object sample is valid" do
    test_data = @official_objects

    {result, _} = MP.validate_objects(test_data)

    assert result == :ok
  end

  ids = ~w(
    country_code
    merchant_category_code
    merchant_city
    merchant_name
    payload_format_indicator
    transaction_currency
  )a

  for id <- ids do
    pretty_name = id |> Atom.to_string() |> String.replace("_", " ")

    test pretty_name <> " is missing" do
      assert_invalid_object([], missing_id: unquote(id))
    end
  end

  test "payload format indicator is not 01" do
    assert_invalid_object([%MPO{id: "00", value: "02"}], invalid_value: :payload_format_indicator)
  end

  test "point of initiation value is not 11 or 12" do
    for value <- ["10", "13"] do
      assert_invalid_object([%MPO{id: "01", value: value}],
        invalid_value: :point_of_initiation_method
      )
    end
  end

  test "both merchant account information (MAI) and MAI template are missing" do
    assert_invalid_object([], missing_id: :merchant_account_information)
  end

  test "merchant account information (MAI) exists but MAI template is missing is valid" do
    test_data = [%MPO{id: "02", value: "ABC"}]
    {:error, reasons} = MP.validate_objects(test_data)

    assert not Enum.member?(
             reasons,
             Exemvi.Error.missing_object_id(:merchant_account_information)
           )
  end

  test "merchant account information (MAI) template exists but MAI is missing is valid" do
    test_data = [%MPO{id: "26", value: "ABC"}]
    {:error, reasons} = MP.validate_objects(test_data)

    assert not Enum.member?(
             reasons,
             Exemvi.Error.missing_object_id(:merchant_account_information)
           )
  end

  test "merchant account information template is parsed into objects" do
    with {:ok, objects} <- MP.parse_to_objects(@official_sample) do
      object_29 = Enum.find(objects, fn x -> x.id == "29" end)

      assert object_29 != nil
      assert object_29.objects != nil
      assert Enum.count(object_29.objects) == 2

      globally_unique_identifier = object_29.objects |> Enum.at(0)
      assert globally_unique_identifier.id == "00"
      assert globally_unique_identifier.value == "D15600000000"

      payment_network_specific = object_29.objects |> Enum.at(1)
      assert payment_network_specific.id == "05"
      assert payment_network_specific.value == "A93FO3230Q"

      object_31 = Enum.find(objects, fn x -> x.id == "31" end)

      assert object_31 != nil
      assert object_31.objects != nil
      assert Enum.count(object_31.objects) == 2

      globally_unique_identifier = object_31.objects |> Enum.at(0)
      assert globally_unique_identifier.id == "00"
      assert globally_unique_identifier.value == "D15600000001"

      payment_network_specific = object_31.objects |> Enum.at(1)
      assert payment_network_specific.id == "03"
      assert payment_network_specific.value == "12345678"
    else
      _ -> assert false, "Failed parsing merchant account information template"
    end
  end

  test "merchant account information template globally unique identifier is missing" do
    assert_invalid_object([%MPO{id: "26", objects: [%MPO{id: "01", value: "ABC"}]}],
      missing_id: :globally_unique_identifier
    )
  end

  test "merchant account information template globally unique identifier is longer than 32 chars" do
    assert_invalid_object(
      [%MPO{id: "26", objects: [%MPO{id: "00", value: String.duplicate("x", 33)}]}],
      invalid_value: :globally_unique_identifier
    )
  end

  test "merchant category code value is not 4 integer digits" do
    for value <- ["12AB", "123", "12345"] do
      assert_invalid_object([%MPO{id: "52", value: value}],
        invalid_value: :merchant_category_code
      )
    end
  end

  test "transaction currency value is not 3 integer digits" do
    for value <- ["12AB", "12", "1234"] do
      assert_invalid_object([%MPO{id: "53", value: value}],
        invalid_value: :transaction_currency
      )
    end
  end

  test "transaction amount value is longer than 13 decimal digits" do
    for value <- [String.duplicate("1", 14), "123456789012.4"] do
      assert_invalid_object([%MPO{id: "54", value: value}],
        invalid_value: :transaction_amount
      )
    end
  end

  test "convenience indicator is not 2 integer digits" do
    for value <- ["1A", "1", "123"] do
      assert_invalid_object([%MPO{id: "55", value: value}],
        invalid_value: :tip_or_convenience_indicator
      )
    end
  end

  test "convenience fee fixed is orphaned" do
    assert_invalid_object([%MPO{id: "56", value: "1"}],
      orphaned: :value_of_convenience_fee_fixed
    )
  end

  test "convenience fee fixed is longer than 13 decimal digits" do
    for value <- [String.duplicate("1", 14), "123456789012.4"] do
      assert_invalid_object([%MPO{id: "56", value: value}],
        invalid_value: :value_of_convenience_fee_fixed
      )
    end
  end

  test "convenience fee percentage is orphaned" do
    assert_invalid_object([%MPO{id: "57", value: "1"}],
      orphaned: :value_of_convenience_fee_percentage
    )
  end

  test "convenience fee percentage is longer than 5 decimal digits" do
    for value <- [String.duplicate("1", 6), "1234.6"] do
      assert_invalid_object([%MPO{id: "57", value: value}],
        invalid_value: :value_of_convenience_fee_percentage
      )
    end
  end

  test "country code is not 2 chars" do
    for value <- ["A", "ABC"] do
      assert_invalid_object([%MPO{id: "58", value: value}],
        invalid_value: :country_code
      )
    end
  end

  test "merchant name is longer than 25 chars" do
    assert_invalid_object([%MPO{id: "59", value: String.duplicate("x", 26)}],
      invalid_value: :merchant_name
    )
  end

  test "merchant city is longer than 15 chars" do
    assert_invalid_object([%MPO{id: "60", value: String.duplicate("x", 16)}],
      invalid_value: :merchant_city
    )
  end

  test "postal code is longer than 10 chars" do
    assert_invalid_object([%MPO{id: "61", value: String.duplicate("x", 11)}],
      invalid_value: :postal_code
    )
  end

  test "additional data template is parsed into objects" do
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

  additional_data_attrs = ~w(
    bill_number
    customer_label
    loyalty_number
    mobile_number
    purpose_of_transaction
    reference_label
    store_label
    terminal_label
  )a

  for attr <- additional_data_attrs do
    pretty_name = attr |> Atom.to_string() |> String.replace("_", " ")

    test "additional data " <> pretty_name <> " is longer than 25 chars" do
      code_62 = MPO.id_raw(:root, :additional_data_field_template)
      code = MPO.id_raw(:additional_data_field_template, unquote(attr))

      assert_invalid_object(
        [%MPO{id: code_62, objects: [%MPO{id: code, value: String.duplicate("x", 26)}]}],
        invalid_value: unquote(attr)
      )
    end
  end

  test "additional data consumer data request is invalid" do
    code_62 = MPO.id_raw(:root, :additional_data_field_template)
    code_09 = MPO.id_raw(:additional_data_field_template, :additional_consumer_data_request)

    for value <- ["AAA", "XYZ", "AMEA"] do
      assert_invalid_object(
        [%MPO{id: code_62, objects: [%MPO{id: code_09, value: value}]}],
        invalid_value: :additional_consumer_data_request
      )
    end
  end

  test "additional data payment system specific template is parsed into object" do
    test_data = "623050260015org.example.www0103ABC"

    with {:ok, objects} <- MP.parse_to_objects(test_data) do
      object_62 = Enum.find(objects, fn x -> x.id == "62" end)

      assert object_62 != nil
      assert object_62.objects != nil
      assert Enum.count(object_62.objects) == 1

      object_62_50 = object_62.objects |> Enum.at(0)
      assert object_62_50.id == "50"
      assert Enum.count(object_62_50.objects) == 2

      globally_unique_identifier = object_62_50.objects |> Enum.at(0)
      assert globally_unique_identifier.id == "00"
      assert globally_unique_identifier.value == "org.example.www"

      payment_system_specific = object_62_50.objects |> Enum.at(1)
      assert payment_system_specific.id == "01"
      assert payment_system_specific.value == "ABC"
    else
      _ -> assert false, "Failed parsing additional data payment system specific template"
    end
  end

  test "additional data payment system specific template globally unique identifier is missing" do
    assert_invalid_object(
      [
        %MPO{
          id: "62",
          objects: [
            %MPO{
              id: "50",
              objects: [
                %MPO{
                  id: "01",
                  value: "ABC"
                }
              ]
            }
          ]
        }
      ],
      missing_id: :globally_unique_identifier
    )
  end

  test "additional data payment system specific template globally unique identifier is longer than 32 chars" do
    assert_invalid_object(
      [
        %MPO{
          id: "62",
          objects: [
            %MPO{
              id: "50",
              objects: [
                %MPO{
                  id: "00",
                  value: String.duplicate("x", 33)
                }
              ]
            }
          ]
        }
      ],
      invalid_value: :globally_unique_identifier
    )
  end

  describe "merchant information language template" do
    setup do
      code_64 = MPO.id_raw(:root, :merchant_information_language_template)

      builder = fn key, value ->
        key =
          cond do
            is_binary(key) -> key
            is_atom(key) -> MPO.id_raw(:merchant_information_language_template, key)
          end

        [%MPO{id: code_64, objects: [%MPO{id: key, value: value}]}]
      end

      %{builder: builder}
    end

    test "is parsed into objects" do
      with {:ok, objects} <- MP.parse_to_objects(@official_sample) do
        id_64_raw = MPO.id_raw(:root, :merchant_information_language_template)
        object_64 = Enum.find(objects, fn x -> x.id == id_64_raw end)

        assert object_64 != nil
        assert object_64.objects != nil
        assert Enum.count(object_64.objects) == 3

        language_preference = object_64.objects |> Enum.at(0)
        assert language_preference.id == "00"
        assert language_preference.value == "ZH"

        merchant_name = object_64.objects |> Enum.at(1)
        assert merchant_name.id == "01"
        assert merchant_name.value == "最佳运输"

        merchant_city = object_64.objects |> Enum.at(2)
        assert merchant_city.id == "02"
        assert merchant_city.value == "北京"
      else
        _ -> assert false, "Failed parsing merchant information language template"
      end
    end

    test "language preference is missing", %{builder: builder} do
      assert_invalid_object(builder.("01", "ABC"), missing_id: :language_preference)
    end

    test "language preference is invalid", %{builder: builder} do
      for value <- ["A", "ABC"] do
        assert_invalid_object(
          builder.(:language_preference, value),
          invalid_value: :language_preference
        )
      end
    end

    test "merchant name alternate language is missing", %{builder: builder} do
      assert_invalid_object(
        builder.("00", "EN"),
        missing_id: :merchant_name_alternate_language
      )
    end

    test "merchant name alternate language is longer than 25 chars", %{builder: builder} do
      assert_invalid_object(
        builder.(:merchant_name_alternate_language, String.duplicate("x", 26)),
        invalid_value: :merchant_name_alternate_language
      )
    end

    test "merchant city alternate language is longer than 15 chars", %{builder: builder} do
      assert_invalid_object(
        builder.(:merchant_city_alternate_language, String.duplicate("x", 16)),
        invalid_value: :merchant_city_alternate_language
      )
    end
  end

  test "unreserved template is parsed into objects" do
    test_data = "80260015org.example.www0103ABC"

    with {:ok, objects} <- MP.parse_to_objects(test_data) do
      object_80 = Enum.find(objects, fn x -> x.id == "80" end)

      assert object_80 != nil
      assert object_80.objects != nil
      assert Enum.count(object_80.objects) == 2

      globally_unique_identifier = object_80.objects |> Enum.at(0)
      assert globally_unique_identifier.id == "00"
      assert globally_unique_identifier.value == "org.example.www"

      context_specific_data = object_80.objects |> Enum.at(1)
      assert context_specific_data.id == "01"
      assert context_specific_data.value == "ABC"
    else
      _ -> assert false, "Failed parsing unreserved template"
    end
  end

  test "unreserved template globally unique identifier is missing" do
    assert_invalid_object(
      [
        %MPO{
          id: "80",
          objects: [
            %MPO{
              id: "01",
              value: "ABC"
            }
          ]
        }
      ],
      missing_id: :globally_unique_identifier
    )
  end

  test "unreserved template globally unique identifier is longer than 32 chars" do
    assert_invalid_object(
      [
        %MPO{
          id: "80",
          objects: [
            %MPO{
              id: "00",
              value: String.duplicate("x", 33)
            }
          ]
        }
      ],
      invalid_value: :globally_unique_identifier
    )
  end
end

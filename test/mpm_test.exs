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

  test "successful" do
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

      assert false, "Additional data 62"

      # Check checksum
      checksum = Enum.at(tlvs, 14)
      assert checksum.data_object == "63"
      assert checksum.data_value == "A13A"
    else
      _ -> assert false, "Parsing failed"
    end
  end

  test "data length is not numeric" do
    payload = "00A201"
    {result, reasons} = Exemvi.MPM.parse(payload)
    assert result == :error
    assert Enum.member?(reasons, :invalid_data_length)
  end

  test "payload format indicator is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) != :payload_format_indicator end)
    {:error, reasons} = Exemvi.MPM.validate(test_data, :mandatory)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:payload_format_indicator))
  end

  test "payload format indicator is invalid" do
    assert false, "TBD"
  end

  test "point of initiation is invalid" do
    assert false, "TBD"
  end

  test "merchant account information is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) != :merchant_account_information end)
    {:error, reasons} = Exemvi.MPM.validate(test_data, :mandatory)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_account_information))
  end

  test "merchant account information is invalid" do
    assert false, "TBD"
  end

  test "merchant category code is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) != :merchant_category_code end)
    {:error, reasons} = Exemvi.MPM.validate(test_data, :mandatory)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_category_code))
  end

  test "merchant category code is invalid" do
    assert false, "TBD"
  end

  test "transaction currency is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) != :transaction_currency end)
    {:error, reasons} = Exemvi.MPM.validate(test_data, :mandatory)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:transaction_currency))
  end

  test "transaction currency is invalid" do
    assert false, "TBD"
  end

  test "convenience indicator is invalid" do
    assert false, "TBD"
  end

  test "convenience fee is orphaned" do
    assert false, "TBD"
  end

  test "convenience fee percentage is orphaned" do
    assert false, "TBD"
  end

  test "country code is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) != :country_code end)
    {:error, reasons} = Exemvi.MPM.validate(test_data, :mandatory)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:country_code))
  end

  test "merchant name is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) != :merchant_name end)
    {:error, reasons} = Exemvi.MPM.validate(test_data, :mandatory)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_name))
  end

  test "merchant city is missing" do
    test_data = Enum.filter(
      @official_tlv,
      fn x -> Exemvi.MPM.DataObject.to_atom(x.data_object) != :merchant_city end)
    {:error, reasons} = Exemvi.MPM.validate(test_data, :mandatory)
    assert Enum.member?(
      reasons,
      Exemvi.Error.missing_data_object(:merchant_city))
  end

  test "checksum is invalid" do
    assert false, "TBD"
  end
end

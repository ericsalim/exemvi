defmodule MPMTest do
  use ExUnit.Case

  test "successful" do
    official_sample = "00020101021229300012D156000000000510A93FO3230Q31280012D15600000001030812345678520441115802CN5914BEST TRANSPORT6007BEIJING64200002ZH0104最佳运输0202北京540523.7253031565502016233030412340603***0708A60086670902ME91320016A0112233449988770708123456786304A13A"

    with {:ok, tlvs} <- Exemvi.MPM.parse(official_sample)
    do
      # Check only some fields

      # Check payload format indicator
      pfi = Enum.at(tlvs, 0)
      assert pfi.data_object == "00"
      assert pfi.data_length == "02"
      assert pfi.data_value == "01"

      # Check merchant information
      merchant_info = Enum.at(tlvs, 8)
      assert merchant_info.data_object == "64"
      assert merchant_info.data_length == "20"
      assert merchant_info.data_value == "0002ZH0104最佳运输0202北京"

      # Check checksum
      checksum = Enum.at(tlvs, 14)
      assert checksum.data_object == "63"
      assert checksum.data_length == "04"
      assert checksum.data_value == "A13A"
    else
      _ -> assert false, "Parsing failed"
    end
  end

  test "invalid data object" do
    assert false, "TBD"
  end

  test "invalid data length" do
    assert false, "TBD"
  end

  test "invalid payload format indicator" do
    assert false, "TBD"
  end

  test "invalid point of initiation" do
    assert false, "TBD"
  end

  test "invalid checksum" do
    assert false, "TBD"
  end
end

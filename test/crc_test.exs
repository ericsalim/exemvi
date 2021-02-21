defmodule CRCTest do
  use ExUnit.Case

  test "calculation is successful 1" do
    mpm_sample = "00020101021229300012D156000000000510A93FO3230Q31280012D15600000001030812345678520441115802CN5914BEST TRANSPORT6007BEIJING64200002ZH0104最佳运输0202北京540523.7253031565502016233030412340603***0708A60086670902ME91320016A0112233449988770708123456786304"
    checksum = Exemvi.CRC.checksum_hex(mpm_sample)
    assert checksum == "A13A"
  end

  test "calculation is successful 2" do
    mpm_sample = "A random string"
    checksum = Exemvi.CRC.checksum_hex(mpm_sample)
    assert checksum == "0375"
  end
end

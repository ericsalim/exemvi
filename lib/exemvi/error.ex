defmodule Exemvi.Error do

  # Must be ordered alphabetically

  def invalid_data_length, do: :invalid_data_length
  def missing_data_object(:payload_format_indicator), do: :missing_payload_format_indicator
  def missing_data_object(:merchant_account_information), do: :missing_merchant_account_information
  def missing_data_object(:merchant_category_code), do: :missing_merchant_category_code
  def missing_data_object(:transaction_currency), do: :missing_transaction_currency
  def missing_data_object(:country_code), do: :missing_country_code
  def missing_data_object(:merchant_name), do: :missing_merchant_name
  def missing_data_object(:merchant_city), do: :missing_merchant_city
  def missing_data_object(:crc), do: :missing_crc
  def missing_mandatory_field, do: :missing_mandatory_field

end

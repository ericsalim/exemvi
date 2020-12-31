defmodule Exemvi.Error do

  # Must be ordered alphabetically

  def invalid_data_length, do: :invalid_data_length
  def invalid_payload, do: :invalid_payload

  def missing_data_object(:payload_format_indicator), do: :missing_payload_format_indicator
  def missing_data_object(:merchant_account_information), do: :missing_merchant_account_information
  def missing_data_object(:merchant_category_code), do: :missing_merchant_category_code
  def missing_data_object(:transaction_currency), do: :missing_transaction_currency
  def missing_data_object(:country_code), do: :missing_country_code
  def missing_data_object(:merchant_name), do: :missing_merchant_name
  def missing_data_object(:merchant_city), do: :missing_merchant_city
  def missing_data_object(:crc), do: :missing_crc

  def invalid_data_object(:payload_format_indicator), do: :invalid_payload_format_indicator
  def invalid_data_object(:point_of_initiation_method), do: :invalid_point_of_initiation_method
  def invalid_data_object(:merchant_category_code), do: :invalid_merchant_category_code
  def invalid_data_object(:transaction_currency), do: :invalid_transaction_currency
  def invalid_data_object(:transaction_amount), do: :invalid_transaction_amount
  def invalid_data_object(:tip_or_convenience_indicator), do: :invalid_tip_or_convenience_indicator
  def invalid_data_object(:value_of_convenience_fee_fixed), do: :invalid_value_of_convenience_fee_fixed
  def invalid_data_object(:value_of_convenience_fee_percentage), do: :invalid_value_of_convenience_fee_percentage
  def invalid_data_object(:country_code), do: :invalid_country_code
  def invalid_data_object(:merchant_name), do: :invalid_merchant_name
  def invalid_data_object(:merchant_city), do: :invalid_merchant_city
  def invalid_data_object(:postal_code), do: :invalid_postal_code
end

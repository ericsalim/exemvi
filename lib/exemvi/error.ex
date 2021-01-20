defmodule Exemvi.Error do

  # Must be ordered alphabetically

  def invalid_data_length, do: :invalid_data_length

  def invalid_object_id, do: :invalid_object_id

  def invalid_object_value(:payload_format_indicator), do: :invalid_payload_format_indicator
  def invalid_object_value(:point_of_initiation_method), do: :invalid_point_of_initiation_method
  def invalid_object_value(:merchant_category_code), do: :invalid_merchant_category_code
  def invalid_object_value(:transaction_currency), do: :invalid_transaction_currency
  def invalid_object_value(:transaction_amount), do: :invalid_transaction_amount
  def invalid_object_value(:tip_or_convenience_indicator), do: :invalid_tip_or_convenience_indicator
  def invalid_object_value(:value_of_convenience_fee_fixed), do: :invalid_value_of_convenience_fee_fixed
  def invalid_object_value(:value_of_convenience_fee_percentage), do: :invalid_value_of_convenience_fee_percentage
  def invalid_object_value(:country_code), do: :invalid_country_code
  def invalid_object_value(:merchant_name), do: :invalid_merchant_name
  def invalid_object_value(:merchant_city), do: :invalid_merchant_city
  def invalid_object_value(:postal_code), do: :invalid_postal_code

  def invalid_qr, do: :invalid_qr

  def missing_object_id(:payload_format_indicator), do: :missing_payload_format_indicator
  def missing_object_id(:merchant_account_information), do: :missing_merchant_account_information
  def missing_object_id(:merchant_category_code), do: :missing_merchant_category_code
  def missing_object_id(:transaction_currency), do: :missing_transaction_currency
  def missing_object_id(:country_code), do: :missing_country_code
  def missing_object_id(:merchant_name), do: :missing_merchant_name
  def missing_object_id(:merchant_city), do: :missing_merchant_city
  def missing_object_id(:crc), do: :missing_crc

  def orphaned_data_object(:value_of_convenience_fee_fixed), do: :orphaned_value_of_convenience_fee_fixed
  def orphaned_data_object(:value_of_convenience_fee_percentage), do: :orphaned_value_of_convenience_fee_percentage

end

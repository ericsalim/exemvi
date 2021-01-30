defmodule Exemvi.Error do

  # Must be ordered alphabetically

  def invalid_value_length, do: :invalid_value_length

  def invalid_object_id, do: :invalid_object_id

  def invalid_object_value(:additional_consumer_data_request), do: :invalid_additional_consumer_data_request
  def invalid_object_value(:bill_number), do: :invalid_bill_number
  def invalid_object_value(:country_code), do: :invalid_country_code
  def invalid_object_value(:customer_label), do: :invalid_customer_label
  def invalid_object_value(:language_preference), do: :invalid_language_preference
  def invalid_object_value(:loyalty_number), do: :invalid_loyalty_number
  def invalid_object_value(:merchant_category_code), do: :invalid_merchant_category_code
  def invalid_object_value(:merchant_city), do: :invalid_merchant_city
  def invalid_object_value(:merchant_city_alternate_language), do: :invalid_merchant_city_alternate_language
  def invalid_object_value(:merchant_name), do: :invalid_merchant_name
  def invalid_object_value(:merchant_name_alternate_language), do: :invalid_merchant_name_alternate_language
  def invalid_object_value(:mobile_number), do: :invalid_mobile_number
  def invalid_object_value(:payload_format_indicator), do: :invalid_payload_format_indicator
  def invalid_object_value(:point_of_initiation_method), do: :invalid_point_of_initiation_method
  def invalid_object_value(:postal_code), do: :invalid_postal_code
  def invalid_object_value(:purpose_of_transaction), do: :invalid_purpose_of_transaction
  def invalid_object_value(:reference_label), do: :reference_label
  def invalid_object_value(:tip_or_convenience_indicator), do: :invalid_tip_or_convenience_indicator
  def invalid_object_value(:transaction_amount), do: :invalid_transaction_amount
  def invalid_object_value(:transaction_currency), do: :invalid_transaction_currency
  def invalid_object_value(:value_of_convenience_fee_fixed), do: :invalid_value_of_convenience_fee_fixed
  def invalid_object_value(:value_of_convenience_fee_percentage), do: :invalid_value_of_convenience_fee_percentage
  def invalid_object_value(:store_label), do: :invalid_store_label
  def invalid_object_value(:terminal_label), do: :invalid_terminal_label

  def invalid_qr, do: :invalid_qr

  def missing_object_id(:country_code), do: :missing_country_code
  def missing_object_id(:crc), do: :missing_crc
  def missing_object_id(:language_preference), do: :missing_language_preference
  def missing_object_id(:merchant_account_information), do: :missing_merchant_account_information
  def missing_object_id(:merchant_category_code), do: :missing_merchant_category_code
  def missing_object_id(:merchant_city), do: :missing_merchant_city
  def missing_object_id(:merchant_name), do: :missing_merchant_name
  def missing_object_id(:merchant_name_alternate_language), do: :missing_merchant_name_alternate_language
  def missing_object_id(:payload_format_indicator), do: :missing_payload_format_indicator
  def missing_object_id(:transaction_currency), do: :missing_transaction_currency

  def orphaned_object(:value_of_convenience_fee_fixed), do: :orphaned_value_of_convenience_fee_fixed
  def orphaned_object(:value_of_convenience_fee_percentage), do: :orphaned_value_of_convenience_fee_percentage

end

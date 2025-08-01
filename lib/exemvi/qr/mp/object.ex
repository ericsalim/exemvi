defmodule Exemvi.QR.MP.Object do
  @moduledoc """
  Merchant-Presented Mode data object

  Properties:
  - `:id` is a string of data object ID
  - `:value` is a string of data object value. The value is `nil` if the data object is a template
  - `:objects` is a list of data objects in the template. The value is `nil` if the data object is not a template

  """

  defstruct [
    :id,
    :value,
    :objects
  ]

  defp root_id_atoms() do
    %{
      "00" => :payload_format_indicator,
      "01" => :point_of_initiation_method,
      "02" => :merchant_account_information,
      "03" => :merchant_account_information,
      "04" => :merchant_account_information,
      "05" => :merchant_account_information,
      "06" => :merchant_account_information,
      "07" => :merchant_account_information,
      "08" => :merchant_account_information,
      "09" => :merchant_account_information,
      "10" => :merchant_account_information,
      "11" => :merchant_account_information,
      "12" => :merchant_account_information,
      "13" => :merchant_account_information,
      "14" => :merchant_account_information,
      "15" => :merchant_account_information,
      "16" => :merchant_account_information,
      "17" => :merchant_account_information,
      "18" => :merchant_account_information,
      "19" => :merchant_account_information,
      "20" => :merchant_account_information,
      "21" => :merchant_account_information,
      "22" => :merchant_account_information,
      "23" => :merchant_account_information,
      "24" => :merchant_account_information,
      "25" => :merchant_account_information,
      "26" => :merchant_account_information_template,
      "27" => :merchant_account_information_template,
      "28" => :merchant_account_information_template,
      "29" => :merchant_account_information_template,
      "30" => :merchant_account_information_template,
      "31" => :merchant_account_information_template,
      "32" => :merchant_account_information_template,
      "33" => :merchant_account_information_template,
      "34" => :merchant_account_information_template,
      "35" => :merchant_account_information_template,
      "36" => :merchant_account_information_template,
      "37" => :merchant_account_information_template,
      "38" => :merchant_account_information_template,
      "39" => :merchant_account_information_template,
      "40" => :merchant_account_information_template,
      "41" => :merchant_account_information_template,
      "42" => :merchant_account_information_template,
      "43" => :merchant_account_information_template,
      "44" => :merchant_account_information_template,
      "45" => :merchant_account_information_template,
      "46" => :merchant_account_information_template,
      "47" => :merchant_account_information_template,
      "48" => :merchant_account_information_template,
      "49" => :merchant_account_information_template,
      "50" => :merchant_account_information_template,
      "51" => :merchant_account_information_template,
      "52" => :merchant_category_code,
      "53" => :transaction_currency,
      "54" => :transaction_amount,
      "55" => :tip_or_convenience_indicator,
      "56" => :value_of_convenience_fee_fixed,
      "57" => :value_of_convenience_fee_percentage,
      "58" => :country_code,
      "59" => :merchant_name,
      "60" => :merchant_city,
      "61" => :postal_code,
      "62" => :additional_data_field_template,
      "63" => :crc,
      "64" => :merchant_information_language_template,
      "65" => :rfu_for_emvco,
      "66" => :rfu_for_emvco,
      "67" => :rfu_for_emvco,
      "68" => :rfu_for_emvco,
      "69" => :rfu_for_emvco,
      "70" => :rfu_for_emvco,
      "71" => :rfu_for_emvco,
      "72" => :rfu_for_emvco,
      "73" => :rfu_for_emvco,
      "74" => :rfu_for_emvco,
      "75" => :rfu_for_emvco,
      "76" => :rfu_for_emvco,
      "77" => :rfu_for_emvco,
      "78" => :rfu_for_emvco,
      "79" => :rfu_for_emvco,
      "80" => :unreserved_template,
      "81" => :unreserved_template,
      "82" => :unreserved_template,
      "83" => :unreserved_template,
      "84" => :unreserved_template,
      "85" => :unreserved_template,
      "86" => :unreserved_template,
      "87" => :unreserved_template,
      "88" => :unreserved_template,
      "89" => :unreserved_template,
      "90" => :unreserved_template,
      "91" => :unreserved_template,
      "92" => :unreserved_template,
      "93" => :unreserved_template,
      "94" => :unreserved_template,
      "95" => :unreserved_template,
      "96" => :unreserved_template,
      "97" => :unreserved_template,
      "98" => :unreserved_template,
      "99" => :unreserved_template
    }
  end

  defp root_specs() do
    %{
      payload_format_indicator: %{
        must: true,
        must_alias: nil,
        min_len: 2,
        max_len: 2,
        regex: ~r/(^01$)/,
        parent: nil,
        is_template: false
      },
      point_of_initiation_method: %{
        must: false,
        must_alias: nil,
        min_len: 2,
        max_len: 2,
        regex: ~r/(^11$)|(^12$)/,
        parent: nil,
        is_template: false
      },
      merchant_account_information: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: false
      },
      merchant_account_information_template: %{
        must: true,
        must_alias: :merchant_account_information,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: true
      },
      merchant_category_code: %{
        must: true,
        must_alias: nil,
        min_len: 4,
        max_len: 4,
        regex: ~r/^\d+$/,
        parent: nil,
        is_template: false
      },
      transaction_currency: %{
        must: true,
        must_alias: nil,
        min_len: 3,
        max_len: 3,
        regex: ~r/^\d+$/,
        parent: nil,
        is_template: false
      },
      transaction_amount: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 13,
        regex: ~r/(^\d+\.\d+$)|(^\d+$)/,
        parent: nil,
        is_template: false
      },
      tip_or_convenience_indicator: %{
        must: false,
        must_alias: nil,
        min_len: 2,
        max_len: 2,
        regex: ~r/^\d+$/,
        parent: nil,
        is_template: false
      },
      value_of_convenience_fee_fixed: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 13,
        regex: ~r/(^\d+\.\d+$)|(^\d+$)/,
        parent: :tip_or_convenience_indicator,
        is_template: false
      },
      value_of_convenience_fee_percentage: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 5,
        regex: ~r/(^\d+\.\d+$)|(^\d+$)/,
        parent: :tip_or_convenience_indicator,
        is_template: false
      },
      country_code: %{
        must: true,
        must_alias: nil,
        min_len: 2,
        max_len: 2,
        regex: ~r/^[a-zA-Z]{2}$/,
        parent: nil,
        is_template: false
      },
      merchant_name: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      merchant_city: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 15,
        regex: nil,
        parent: nil,
        is_template: false
      },
      postal_code: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 10,
        regex: nil,
        parent: nil,
        is_template: false
      },
      additional_data_field_template: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: true
      },
      crc: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 4,
        regex: nil,
        parent: nil,
        is_template: false
      },
      merchant_information_language_template: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: true
      },
      rfu_for_emvco: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: false
      },
      unreserved_template: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: true
      }
    }
  end

  defp id_26_to_51_id_atoms() do
    %{
      "00" => :globally_unique_identifier,
      "01" => :payment_network_specific,
      "02" => :payment_network_specific,
      "03" => :payment_network_specific,
      "04" => :payment_network_specific,
      "05" => :payment_network_specific,
      "06" => :payment_network_specific,
      "07" => :payment_network_specific,
      "08" => :payment_network_specific,
      "09" => :payment_network_specific,
      "10" => :payment_network_specific,
      "11" => :payment_network_specific,
      "12" => :payment_network_specific,
      "13" => :payment_network_specific,
      "14" => :payment_network_specific,
      "15" => :payment_network_specific,
      "16" => :payment_network_specific,
      "17" => :payment_network_specific,
      "18" => :payment_network_specific,
      "19" => :payment_network_specific,
      "20" => :payment_network_specific,
      "21" => :payment_network_specific,
      "22" => :payment_network_specific,
      "23" => :payment_network_specific,
      "24" => :payment_network_specific,
      "25" => :payment_network_specific,
      "26" => :payment_network_specific,
      "27" => :payment_network_specific,
      "28" => :payment_network_specific,
      "29" => :payment_network_specific,
      "30" => :payment_network_specific,
      "31" => :payment_network_specific,
      "32" => :payment_network_specific,
      "33" => :payment_network_specific,
      "34" => :payment_network_specific,
      "35" => :payment_network_specific,
      "36" => :payment_network_specific,
      "37" => :payment_network_specific,
      "38" => :payment_network_specific,
      "39" => :payment_network_specific,
      "40" => :payment_network_specific,
      "41" => :payment_network_specific,
      "42" => :payment_network_specific,
      "43" => :payment_network_specific,
      "44" => :payment_network_specific,
      "45" => :payment_network_specific,
      "46" => :payment_network_specific,
      "47" => :payment_network_specific,
      "48" => :payment_network_specific,
      "49" => :payment_network_specific,
      "50" => :payment_network_specific,
      "51" => :payment_network_specific,
      "52" => :payment_network_specific,
      "53" => :payment_network_specific,
      "54" => :payment_network_specific,
      "55" => :payment_network_specific,
      "56" => :payment_network_specific,
      "57" => :payment_network_specific,
      "58" => :payment_network_specific,
      "59" => :payment_network_specific,
      "60" => :payment_network_specific,
      "61" => :payment_network_specific,
      "62" => :payment_network_specific,
      "63" => :payment_network_specific,
      "64" => :payment_network_specific,
      "65" => :payment_network_specific,
      "66" => :payment_network_specific,
      "67" => :payment_network_specific,
      "68" => :payment_network_specific,
      "69" => :payment_network_specific,
      "70" => :payment_network_specific,
      "71" => :payment_network_specific,
      "72" => :payment_network_specific,
      "73" => :payment_network_specific,
      "74" => :payment_network_specific,
      "75" => :payment_network_specific,
      "76" => :payment_network_specific,
      "77" => :payment_network_specific,
      "78" => :payment_network_specific,
      "79" => :payment_network_specific,
      "80" => :payment_network_specific,
      "81" => :payment_network_specific,
      "82" => :payment_network_specific,
      "83" => :payment_network_specific,
      "84" => :payment_network_specific,
      "85" => :payment_network_specific,
      "86" => :payment_network_specific,
      "87" => :payment_network_specific,
      "88" => :payment_network_specific,
      "89" => :payment_network_specific,
      "90" => :payment_network_specific,
      "91" => :payment_network_specific,
      "92" => :payment_network_specific,
      "93" => :payment_network_specific,
      "94" => :payment_network_specific,
      "95" => :payment_network_specific,
      "96" => :payment_network_specific,
      "97" => :payment_network_specific,
      "98" => :payment_network_specific,
      "99" => :payment_network_specific
    }
  end

  defp id_26_to_51_specs() do
    %{
      globally_unique_identifier: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 32,
        regex: nil,
        parent: nil,
        is_template: false
      },
      payment_network_specific: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: false
      }
    }
  end

  defp id_62_id_atoms() do
    %{
      "01" => :bill_number,
      "02" => :mobile_number,
      "03" => :store_label,
      "04" => :loyalty_number,
      "05" => :reference_label,
      "06" => :customer_label,
      "07" => :terminal_label,
      "08" => :purpose_of_transaction,
      "09" => :additional_consumer_data_request,
      "10" => :rfu_for_emvco,
      "11" => :rfu_for_emvco,
      "12" => :rfu_for_emvco,
      "13" => :rfu_for_emvco,
      "14" => :rfu_for_emvco,
      "15" => :rfu_for_emvco,
      "16" => :rfu_for_emvco,
      "17" => :rfu_for_emvco,
      "18" => :rfu_for_emvco,
      "19" => :rfu_for_emvco,
      "20" => :rfu_for_emvco,
      "21" => :rfu_for_emvco,
      "22" => :rfu_for_emvco,
      "23" => :rfu_for_emvco,
      "24" => :rfu_for_emvco,
      "25" => :rfu_for_emvco,
      "26" => :rfu_for_emvco,
      "27" => :rfu_for_emvco,
      "28" => :rfu_for_emvco,
      "29" => :rfu_for_emvco,
      "30" => :rfu_for_emvco,
      "31" => :rfu_for_emvco,
      "32" => :rfu_for_emvco,
      "33" => :rfu_for_emvco,
      "34" => :rfu_for_emvco,
      "35" => :rfu_for_emvco,
      "36" => :rfu_for_emvco,
      "37" => :rfu_for_emvco,
      "38" => :rfu_for_emvco,
      "39" => :rfu_for_emvco,
      "40" => :rfu_for_emvco,
      "41" => :rfu_for_emvco,
      "42" => :rfu_for_emvco,
      "43" => :rfu_for_emvco,
      "44" => :rfu_for_emvco,
      "45" => :rfu_for_emvco,
      "46" => :rfu_for_emvco,
      "47" => :rfu_for_emvco,
      "48" => :rfu_for_emvco,
      "49" => :rfu_for_emvco,
      "50" => :payment_system_specific_template,
      "51" => :payment_system_specific_template,
      "52" => :payment_system_specific_template,
      "53" => :payment_system_specific_template,
      "54" => :payment_system_specific_template,
      "55" => :payment_system_specific_template,
      "56" => :payment_system_specific_template,
      "57" => :payment_system_specific_template,
      "58" => :payment_system_specific_template,
      "59" => :payment_system_specific_template,
      "60" => :payment_system_specific_template,
      "61" => :payment_system_specific_template,
      "62" => :payment_system_specific_template,
      "63" => :payment_system_specific_template,
      "64" => :payment_system_specific_template,
      "65" => :payment_system_specific_template,
      "66" => :payment_system_specific_template,
      "67" => :payment_system_specific_template,
      "68" => :payment_system_specific_template,
      "69" => :payment_system_specific_template,
      "70" => :payment_system_specific_template,
      "71" => :payment_system_specific_template,
      "72" => :payment_system_specific_template,
      "73" => :payment_system_specific_template,
      "74" => :payment_system_specific_template,
      "75" => :payment_system_specific_template,
      "76" => :payment_system_specific_template,
      "77" => :payment_system_specific_template,
      "78" => :payment_system_specific_template,
      "79" => :payment_system_specific_template,
      "80" => :payment_system_specific_template,
      "81" => :payment_system_specific_template,
      "82" => :payment_system_specific_template,
      "83" => :payment_system_specific_template,
      "84" => :payment_system_specific_template,
      "85" => :payment_system_specific_template,
      "86" => :payment_system_specific_template,
      "87" => :payment_system_specific_template,
      "88" => :payment_system_specific_template,
      "89" => :payment_system_specific_template,
      "90" => :payment_system_specific_template,
      "91" => :payment_system_specific_template,
      "92" => :payment_system_specific_template,
      "93" => :payment_system_specific_template,
      "94" => :payment_system_specific_template,
      "95" => :payment_system_specific_template,
      "96" => :payment_system_specific_template,
      "97" => :payment_system_specific_template,
      "98" => :payment_system_specific_template,
      "99" => :payment_system_specific_template
    }
  end

  defp id_62_specs() do
    %{
      bill_number: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      mobile_number: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      store_label: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      loyalty_number: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      reference_label: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      customer_label: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      terminal_label: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      purpose_of_transaction: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      additional_consumer_data_request: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 3,
        regex:
          ~r/(^A$)|(^M$)|(^E$)|(^AM$)|(^AE$)|(^MA$)|(^ME$)|(^EA$)|(EM$)|(^AME$)|(^AEM$)|(^MAE$)|(^MEA$)|(^EAM$)|(^EMA$)/,
        parent: nil,
        is_template: false
      },
      rfu_for_emvco: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: false
      },
      payment_system_specific_template: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: true
      }
    }
  end

  defp id_62_01_to_99_atoms() do
    %{
      "00" => :globally_unique_identifier,
      "01" => :payment_system_specific,
      "02" => :payment_system_specific,
      "03" => :payment_system_specific,
      "04" => :payment_system_specific,
      "05" => :payment_system_specific,
      "06" => :payment_system_specific,
      "07" => :payment_system_specific,
      "08" => :payment_system_specific,
      "09" => :payment_system_specific,
      "10" => :payment_system_specific,
      "11" => :payment_system_specific,
      "12" => :payment_system_specific,
      "13" => :payment_system_specific,
      "14" => :payment_system_specific,
      "15" => :payment_system_specific,
      "16" => :payment_system_specific,
      "17" => :payment_system_specific,
      "18" => :payment_system_specific,
      "19" => :payment_system_specific,
      "20" => :payment_system_specific,
      "21" => :payment_system_specific,
      "22" => :payment_system_specific,
      "23" => :payment_system_specific,
      "24" => :payment_system_specific,
      "25" => :payment_system_specific,
      "26" => :payment_system_specific,
      "27" => :payment_system_specific,
      "28" => :payment_system_specific,
      "29" => :payment_system_specific,
      "30" => :payment_system_specific,
      "31" => :payment_system_specific,
      "32" => :payment_system_specific,
      "33" => :payment_system_specific,
      "34" => :payment_system_specific,
      "35" => :payment_system_specific,
      "36" => :payment_system_specific,
      "37" => :payment_system_specific,
      "38" => :payment_system_specific,
      "39" => :payment_system_specific,
      "40" => :payment_system_specific,
      "41" => :payment_system_specific,
      "42" => :payment_system_specific,
      "43" => :payment_system_specific,
      "44" => :payment_system_specific,
      "45" => :payment_system_specific,
      "46" => :payment_system_specific,
      "47" => :payment_system_specific,
      "48" => :payment_system_specific,
      "49" => :payment_system_specific,
      "50" => :payment_system_specific,
      "51" => :payment_system_specific,
      "52" => :payment_system_specific,
      "53" => :payment_system_specific,
      "54" => :payment_system_specific,
      "55" => :payment_system_specific,
      "56" => :payment_system_specific,
      "57" => :payment_system_specific,
      "58" => :payment_system_specific,
      "59" => :payment_system_specific,
      "60" => :payment_system_specific,
      "61" => :payment_system_specific,
      "62" => :payment_system_specific,
      "63" => :payment_system_specific,
      "64" => :payment_system_specific,
      "65" => :payment_system_specific,
      "66" => :payment_system_specific,
      "67" => :payment_system_specific,
      "68" => :payment_system_specific,
      "69" => :payment_system_specific,
      "70" => :payment_system_specific,
      "71" => :payment_system_specific,
      "72" => :payment_system_specific,
      "73" => :payment_system_specific,
      "74" => :payment_system_specific,
      "75" => :payment_system_specific,
      "76" => :payment_system_specific,
      "77" => :payment_system_specific,
      "78" => :payment_system_specific,
      "79" => :payment_system_specific,
      "80" => :payment_system_specific,
      "81" => :payment_system_specific,
      "82" => :payment_system_specific,
      "83" => :payment_system_specific,
      "84" => :payment_system_specific,
      "85" => :payment_system_specific,
      "86" => :payment_system_specific,
      "87" => :payment_system_specific,
      "88" => :payment_system_specific,
      "89" => :payment_system_specific,
      "90" => :payment_system_specific,
      "91" => :payment_system_specific,
      "92" => :payment_system_specific,
      "93" => :payment_system_specific,
      "94" => :payment_system_specific,
      "95" => :payment_system_specific,
      "96" => :payment_system_specific,
      "97" => :payment_system_specific,
      "98" => :payment_system_specific,
      "99" => :payment_system_specific
    }
  end

  defp id_62_01_to_99_specs() do
    %{
      globally_unique_identifier: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 32,
        regex: nil,
        parent: nil,
        is_template: false
      },
      payment_system_specific: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: false
      }
    }
  end

  defp id_64_id_atoms() do
    %{
      "00" => :language_preference,
      "01" => :merchant_name_alternate_language,
      "02" => :merchant_city_alternate_language,
      "03" => :rfu_for_emvco,
      "04" => :rfu_for_emvco,
      "05" => :rfu_for_emvco,
      "06" => :rfu_for_emvco,
      "07" => :rfu_for_emvco,
      "08" => :rfu_for_emvco,
      "09" => :rfu_for_emvco,
      "10" => :rfu_for_emvco,
      "11" => :rfu_for_emvco,
      "12" => :rfu_for_emvco,
      "13" => :rfu_for_emvco,
      "14" => :rfu_for_emvco,
      "15" => :rfu_for_emvco,
      "16" => :rfu_for_emvco,
      "17" => :rfu_for_emvco,
      "18" => :rfu_for_emvco,
      "19" => :rfu_for_emvco,
      "20" => :rfu_for_emvco,
      "21" => :rfu_for_emvco,
      "22" => :rfu_for_emvco,
      "23" => :rfu_for_emvco,
      "24" => :rfu_for_emvco,
      "25" => :rfu_for_emvco,
      "26" => :rfu_for_emvco,
      "27" => :rfu_for_emvco,
      "28" => :rfu_for_emvco,
      "29" => :rfu_for_emvco,
      "30" => :rfu_for_emvco,
      "31" => :rfu_for_emvco,
      "32" => :rfu_for_emvco,
      "33" => :rfu_for_emvco,
      "34" => :rfu_for_emvco,
      "35" => :rfu_for_emvco,
      "36" => :rfu_for_emvco,
      "37" => :rfu_for_emvco,
      "38" => :rfu_for_emvco,
      "39" => :rfu_for_emvco,
      "40" => :rfu_for_emvco,
      "41" => :rfu_for_emvco,
      "42" => :rfu_for_emvco,
      "43" => :rfu_for_emvco,
      "44" => :rfu_for_emvco,
      "45" => :rfu_for_emvco,
      "46" => :rfu_for_emvco,
      "47" => :rfu_for_emvco,
      "48" => :rfu_for_emvco,
      "49" => :rfu_for_emvco,
      "50" => :rfu_for_emvco,
      "51" => :rfu_for_emvco,
      "52" => :rfu_for_emvco,
      "53" => :rfu_for_emvco,
      "54" => :rfu_for_emvco,
      "55" => :rfu_for_emvco,
      "56" => :rfu_for_emvco,
      "57" => :rfu_for_emvco,
      "58" => :rfu_for_emvco,
      "59" => :rfu_for_emvco,
      "60" => :rfu_for_emvco,
      "61" => :rfu_for_emvco,
      "62" => :rfu_for_emvco,
      "63" => :rfu_for_emvco,
      "64" => :rfu_for_emvco,
      "65" => :rfu_for_emvco,
      "66" => :rfu_for_emvco,
      "67" => :rfu_for_emvco,
      "68" => :rfu_for_emvco,
      "69" => :rfu_for_emvco,
      "70" => :rfu_for_emvco,
      "71" => :rfu_for_emvco,
      "72" => :rfu_for_emvco,
      "73" => :rfu_for_emvco,
      "74" => :rfu_for_emvco,
      "75" => :rfu_for_emvco,
      "76" => :rfu_for_emvco,
      "77" => :rfu_for_emvco,
      "78" => :rfu_for_emvco,
      "79" => :rfu_for_emvco,
      "80" => :rfu_for_emvco,
      "81" => :rfu_for_emvco,
      "82" => :rfu_for_emvco,
      "83" => :rfu_for_emvco,
      "84" => :rfu_for_emvco,
      "85" => :rfu_for_emvco,
      "86" => :rfu_for_emvco,
      "87" => :rfu_for_emvco,
      "88" => :rfu_for_emvco,
      "89" => :rfu_for_emvco,
      "90" => :rfu_for_emvco,
      "91" => :rfu_for_emvco,
      "92" => :rfu_for_emvco,
      "93" => :rfu_for_emvco,
      "94" => :rfu_for_emvco,
      "95" => :rfu_for_emvco,
      "96" => :rfu_for_emvco,
      "97" => :rfu_for_emvco,
      "98" => :rfu_for_emvco,
      "99" => :rfu_for_emvco
    }
  end

  defp id_64_specs() do
    %{
      language_preference: %{
        must: true,
        must_alias: nil,
        min_len: 2,
        max_len: 2,
        regex: nil,
        parent: nil,
        is_template: false
      },
      merchant_name_alternate_language: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 25,
        regex: nil,
        parent: nil,
        is_template: false
      },
      merchant_city_alternate_language: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 15,
        regex: nil,
        parent: nil,
        is_template: false
      },
      rfu_for_emvco: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: false
      }
    }
  end

  defp id_80_to_99_id_atoms() do
    %{
      "00" => :globally_unique_identifier,
      "01" => :context_specific_data,
      "02" => :context_specific_data,
      "03" => :context_specific_data,
      "04" => :context_specific_data,
      "05" => :context_specific_data,
      "06" => :context_specific_data,
      "07" => :context_specific_data,
      "08" => :context_specific_data,
      "09" => :context_specific_data,
      "10" => :context_specific_data,
      "11" => :context_specific_data,
      "12" => :context_specific_data,
      "13" => :context_specific_data,
      "14" => :context_specific_data,
      "15" => :context_specific_data,
      "16" => :context_specific_data,
      "17" => :context_specific_data,
      "18" => :context_specific_data,
      "19" => :context_specific_data,
      "20" => :context_specific_data,
      "21" => :context_specific_data,
      "22" => :context_specific_data,
      "23" => :context_specific_data,
      "24" => :context_specific_data,
      "25" => :context_specific_data,
      "26" => :context_specific_data,
      "27" => :context_specific_data,
      "28" => :context_specific_data,
      "29" => :context_specific_data,
      "30" => :context_specific_data,
      "31" => :context_specific_data,
      "32" => :context_specific_data,
      "33" => :context_specific_data,
      "34" => :context_specific_data,
      "35" => :context_specific_data,
      "36" => :context_specific_data,
      "37" => :context_specific_data,
      "38" => :context_specific_data,
      "39" => :context_specific_data,
      "40" => :context_specific_data,
      "41" => :context_specific_data,
      "42" => :context_specific_data,
      "43" => :context_specific_data,
      "44" => :context_specific_data,
      "45" => :context_specific_data,
      "46" => :context_specific_data,
      "47" => :context_specific_data,
      "48" => :context_specific_data,
      "49" => :context_specific_data,
      "50" => :context_specific_data,
      "51" => :context_specific_data,
      "52" => :context_specific_data,
      "53" => :context_specific_data,
      "54" => :context_specific_data,
      "55" => :context_specific_data,
      "56" => :context_specific_data,
      "57" => :context_specific_data,
      "58" => :context_specific_data,
      "59" => :context_specific_data,
      "60" => :context_specific_data,
      "61" => :context_specific_data,
      "62" => :context_specific_data,
      "63" => :context_specific_data,
      "64" => :context_specific_data,
      "65" => :context_specific_data,
      "66" => :context_specific_data,
      "67" => :context_specific_data,
      "68" => :context_specific_data,
      "69" => :context_specific_data,
      "70" => :context_specific_data,
      "71" => :context_specific_data,
      "72" => :context_specific_data,
      "73" => :context_specific_data,
      "74" => :context_specific_data,
      "75" => :context_specific_data,
      "76" => :context_specific_data,
      "77" => :context_specific_data,
      "78" => :context_specific_data,
      "79" => :context_specific_data,
      "80" => :context_specific_data,
      "81" => :context_specific_data,
      "82" => :context_specific_data,
      "83" => :context_specific_data,
      "84" => :context_specific_data,
      "85" => :context_specific_data,
      "86" => :context_specific_data,
      "87" => :context_specific_data,
      "88" => :context_specific_data,
      "89" => :context_specific_data,
      "90" => :context_specific_data,
      "91" => :context_specific_data,
      "92" => :context_specific_data,
      "93" => :context_specific_data,
      "94" => :context_specific_data,
      "95" => :context_specific_data,
      "96" => :context_specific_data,
      "97" => :context_specific_data,
      "98" => :context_specific_data,
      "99" => :context_specific_data
    }
  end

  defp id_80_to_99_specs() do
    %{
      globally_unique_identifier: %{
        must: true,
        must_alias: nil,
        min_len: 1,
        max_len: 32,
        regex: nil,
        parent: nil,
        is_template: false
      },
      context_specific_data: %{
        must: false,
        must_alias: nil,
        min_len: 1,
        max_len: 99,
        regex: nil,
        parent: nil,
        is_template: false
      }
    }
  end

  @doc false
  def id_atoms(:root) do
    root_id_atoms()
  end

  def id_atoms(:merchant_account_information_template) do
    id_26_to_51_id_atoms()
  end

  def id_atoms(:additional_data_field_template) do
    id_62_id_atoms()
  end

  def id_atoms(:payment_system_specific_template) do
    id_62_01_to_99_atoms()
  end

  def id_atoms(:merchant_information_language_template) do
    id_64_id_atoms()
  end

  def id_atoms(:unreserved_template) do
    id_80_to_99_id_atoms()
  end

  @doc false
  def specs(:root) do
    root_specs()
  end

  def specs(:merchant_account_information_template) do
    id_26_to_51_specs()
  end

  def specs(:additional_data_field_template) do
    id_62_specs()
  end

  def specs(:payment_system_specific_template) do
    id_62_01_to_99_specs()
  end

  def specs(:merchant_information_language_template) do
    id_64_specs()
  end

  def specs(:unreserved_template) do
    id_80_to_99_specs()
  end
end

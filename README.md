# Exemvi

Exemvi is a library to work with EMV QR Code Specification for Payment Systems.

Exemvi only supports validating and parsing Merchant-Presented Mode (MPM) QR Code. Support for generating MPM QR Code is planned for future versions.

At this moment, support for Consumer-Presented Mode (CPM) is not planned.

The specifications of EMV QR Code can be found at https://www.emvco.com/emv-technologies/qrcodes/

# Installation

Add `exemvi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exemvi, "~> 0.1.0"}
  ]
end
```

# Basic Usage

1. Validating the whole QR Code:
   ```elixir
   qr_code = "qr_code_string"
   result = Exemvi.QR.MP.validate_qr(qr_code)
   ```

   The `result` is either:
   - `{:ok, qr_code}` where `qr_code` is the QR Code orginally supplied to the function
   - `{:error, reasons}` where `reasons` is a list of validation error reasons as atoms

2. Parsing QR Code into data objects:
   ```elixir
   qr_code = "qr_code_string"
   result = Exemvi.QR.MP.parse_to_objects(qr_code)
   ```

   The `result` is either:
   - `{:ok, objects}` where `objects` is a list of `Exemvi.MP.Object` structs
   - `{:error, reasons}` where `reasons` is a list of parsing error reasons as atoms

3. Validating parsed data objects:
   ```elixir
   objects = [%Exemvi.QR.MP.Object{id: "00", value: "01"}, ...]
   result = Exemvi.QR.MP.validate_objects(qr_code)
   ```

   The `result` is either:
   - `{:ok, objects}` where `objects` is the objects originally supplied to the function
   - `{:error, reasons}` where `reasons` is a list of validation error reasons as atoms

4. All three functions above can be piped:
   ```elixir
   result = qr_code
            |> Exemvi.QR.MP.validate_qr()
            |> Exemvi.QR.MP.parse_to_objects()
            |> Exemvi.QR.MP.validate_objects()
   ```

All possible error reason atoms in this library are in `Exemvi.Error` module.

# Example

Let's try parsing the official sample.

```elixir
official_sample = "00020101021229300012D156000000000510A93FO3230Q31280012D15600000001030812345678520441115802CN5914BEST TRANSPORT6007BEIJING64200002ZH0104最佳运输0202北京540523.7253031565502016233030412340603***0708A60086670902ME91320016A0112233449988770708123456786304A13A"

{:ok, objects} <- Exemvi.QR.MP.parse_to_objects(official_sample)
```

The resulting objects looks like below:

```elixir
[
  %Exemvi.QR.MP.Object{id: "00", objects: nil, value: "01"},
  %Exemvi.QR.MP.Object{id: "01", objects: nil, value: "12"},
  %Exemvi.QR.MP.Object{
    id: "29",
    objects: [
      %Exemvi.QR.MP.Object{id: "00", objects: nil, value: "D15600000000"},
      %Exemvi.QR.MP.Object{id: "05", objects: nil, value: "A93FO3230Q"}
    ],
    value: nil
  },
  %Exemvi.QR.MP.Object{
    id: "31",
    objects: [
      %Exemvi.QR.MP.Object{id: "00", objects: nil, value: "D15600000001"},
      %Exemvi.QR.MP.Object{id: "03", objects: nil, value: "12345678"}
    ],
    value: nil
  },
  #... Other objects are removed for brevity
]
```

Let's try validating an obviously invalid QR Code.

```elixir
wrong_qr_code = "0002XX"
{:error, reasons} = Exemvi.QR.MP.validate_qr(wrong_qr_code)
```

The resulting error reason is `[:invalid_qr]`

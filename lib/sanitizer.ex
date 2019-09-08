defmodule Calculator.Sanitizer do
  @moduledoc """
  Sanitizes the Record with errors and invalid parameters. This could be highly improved with the use of `Ecto` 
  and changesets. But for this specific use case this module can be easily modified and works well.
  """
  
  alias Calculator.Record
  alias Calculator.Parser

  defp invalid_phone?(record = %Record{}) do
    Map.take(record, [:call_from, :call_to])
    |> Enum.all?(fn {_key, phone} ->
      !String.match?(phone, Parser.phone_pattern())
    end)
  end

  defp invalid_call?(record = %Record{}) do
    record.call_from == record.call_to
  end

  defp invalid_time?(record = %Record{}) do
    record
    |> Map.take([:start_time, :end_time])
    |> Enum.any?(fn {_key, value} -> value == :error end)
  end

  @doc ~S"""
  
  Sanitizes a record and returns the validation status.

  ## Examples

      iex> record = %Calculator.Record{
      ...> call_from: "+351914374373",
      ...> call_to: "+351963433432",
      ...> end_time: "17:49:30",
      ...> start_time: "17:44:04"
      ...> }
      iex> Calculator.Sanitizer.sanitize(record)
      {:ok, %Calculator.Record{
        call_from: "+351914374373",
        call_to: "+351963433432",
        end_time: "17:49:30",
        start_time: "17:44:04"
      }}

      iex> invalid_time = %Calculator.Record{
      ...> call_from: "+351914374373",
      ...> call_to: "+351963433432",
      ...> end_time: "17:49:30",
      ...> start_time: :error # Coming from the parsing functions
      ...> }
      ...> Calculator.Sanitizer.sanitize(invalid_time)
      {:error, %Calculator.Record{
        call_from: "+351914374373",
        call_to: "+351963433432",
        end_time: "17:49:30",
        start_time: :error
      }, "INVALID TIME"}

      iex> invalid_phone = %Calculator.Record{
      ...> call_from: "+35191437437a", # Mind the "a" at the end
      ...> call_to: "+35196343343", # Missing 1 number
      ...> end_time: "17:49:30",
      ...> start_time: :error # Coming from the parsing functions
      ...> }
      ...> Calculator.Sanitizer.sanitize(invalid_phone)
      {:error, %Calculator.Record{
        call_from: "+35191437437a", # Mind the "a" at the end
        call_to: "+35196343343", # Missing 1 number
        end_time: "17:49:30",
        start_time: :error # Coming from the parsing functions
      }, "INVALID PHONE"}

  """
  def sanitize(%Record{} = record) do
    cond do
      invalid_phone?(record) -> {:error, record, "INVALID PHONE"}
      invalid_call?(record) -> {:error, record, "INVALID CALL"}
      invalid_time?(record) -> {:error, record, "INVALID TIME"}
      true -> {:ok, record}
    end
  end
end

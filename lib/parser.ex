defmodule Calculator.Parser do
  @moduledoc """
  Parser for the time and other rules of the `Calculator.Record`
  """
  
  alias Calculator.Record

  @phone_pattern ~r/^\+[0-9]{12}/
  @time_pattern ~r/^(([0-9]){2}:){2}[0-9]{2}/
  @time_unit_zero_based_pattern ~r/^0[0-9]/
  @time_unit_pattern ~r/^[0-9]{2}/

  @doc false
  def phone_pattern(), do: @phone_pattern

  @doc ~S"""

  Parses the time fields of the record to `Time`.

  > Note: For good principles I guess the solo responsibility of this function should parse time. But I would feel
  bothered to merge it elsewhere since this function whould always require the merge to happen immediatelly 
  after anyways.

  ## Examples
  
      iex> record = %Calculator.Record{
      ...>  call_from: "+351914374373",
      ...>  call_to: "+351963433432",
      ...>  end_time: "17:49:30",
      ...>  start_time: "17:44:04"
      ...>  }
      
      iex> Calculator.Parser.parse_time(record)
      %Calculator.Record{
        call_from: "+351914374373",
        call_to: "+351963433432",
        end_time: ~T[17:49:30],
        start_time: ~T[17:44:04]
      }
  """
  def parse_time(record = %Record{}) do
    parsed_time =
      Map.take(record, [:start_time, :end_time])
      |> Enum.into(%{}, &parse_time/1)
    Map.merge(record, parsed_time)
  end

  @doc false
  def parse_time({key, time}) do
    with true <- String.match?(time, @time_pattern),
         {:ok, valid_time} <- new_time(time) do
      {key, valid_time}
    else
      _ -> {key, :error}
    end
  end

  defp new_time(time) when is_bitstring(time) do
    String.split(time, ":")
    |> Enum.into([], fn t -> convert(t) end)
    |> new_time()
  end

  defp new_time([h, m, s]) do
    Time.new(h, m, s)
  end

  defp start_with_zero?(unit) do
    cond do
      String.match?(unit, @time_unit_zero_based_pattern) -> :start_zero
      String.match?(unit, @time_unit_pattern) -> :non_zero
      true -> :error
    end
  end

  defp convert(unit) do
    case start_with_zero?(unit) do
      :start_zero ->
        String.at(unit, 1)
        |> String.to_integer()

      :non_zero ->
        String.to_integer(unit)
      _ -> :error
    end
  end
end

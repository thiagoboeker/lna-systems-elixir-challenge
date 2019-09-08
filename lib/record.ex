defmodule Calculator.Record do
  @moduledoc """
  Registries are parsed to a `%Calculator.Record` struct to further manipulation.
  """
  
  alias Calculator.Record

  @doc false
  defstruct start_time: nil, end_time: nil, call_from: nil, call_to: nil

  @doc ~S"""
  
  Parses a record to struct

  ## Examples

      iex> Calculator.Record.parse_record("09:11:00;09:15:22;+351914374373;+351215355312")
      %Calculator.Record{
        call_from: "+351914374373",
        call_to: "+351215355312",
        end_time: "09:15:22",
        start_time: "09:11:00"
      }

  """
  def parse_record(record) do
    [start_time, end_time, call_from, call_to] = String.split(record, ";")

    %Record{
      start_time: start_time,
      end_time: end_time,
      call_from: call_from,
      call_to: call_to
    }
  end
end

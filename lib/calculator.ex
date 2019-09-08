defmodule Calculator do
  @moduledoc """
  This module provides the necessary pieces to run the computation on the calls file. Some key choices 
  are the use of `Stream` module to optmize memory usage and composability.  
  """

  alias Calculator.Record
  alias Calculator.Sanitizer
  alias Calculator.Parser
  alias Calculator.Billage

  @rules %{
    first: {5, :minute, 5, :cents},
    remainer: {1, :minute, 2, :cents}
  }

  @doc false
  def get_rules(), do: @rules

  @doc """
  
  Runs the computation on a given file with its path.

  """
  def compute(data) do
    data
    |> Stream.map(&Record.parse_record/1)
    |> Stream.map(&Parser.parse_time/1)
    |> Stream.map(&Sanitizer.sanitize/1)
    |> Stream.map(&Billage.calculate_time/1)
    |> Stream.map(&Billage.billing/1)
    #End of stream
    |> Billage.prepare()
    |> Billage.scan_for_the_highest()
    |> Billage.reducer()
    |> Float.ceil(2)
  end

  def run(data) do
    compute(data)
    |> IO.inspect
  end
end

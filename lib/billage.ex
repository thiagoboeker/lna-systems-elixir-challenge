defmodule Calculator.Billage do  
  @moduledoc """
  Module to calculate the time and billing for the calls.
  """

  @doc ~S"""

  Receives from the stream a valid record with a duration and calculates the value
  for billage.

  ## Examples

      iex> Calculator.Billage.billing({:ok, %{duration: 330, record: record}}, rules)
      {:ok, %{duration: 330, record: record, billing: 26}}
  """
  def billing({:ok, %{duration: duration, record: record}}) do
    rules = Calculator.get_rules()
    {factor, _, value, _} = rules.first
    {remainer_factor, _, remainer_value, _} = rules.remainer

    bill = 
      {duration, factor, value}
        |> first()
        |> remainer(remainer_factor, remainer_value)
        |> Float.ceil(2)
    {:ok, %{duration: duration, record: record, billing: bill}}
  end

  @doc false
  def billing({:error, _record, _reason} = error), do: error
  
  @doc ~S"""
  Reducer for the stream of events on billing.

  ## Examples

      iex> Enum.reduce([{:ok, %{billing: 30}}], 30, &Calculator.Billage.reducer/2)
      60
  """
  def reducer({:ok, %{billing: bill}}, acc) do
    acc + bill
  end
  
  @doc false
  def reducer({:error, _record, _reason}, acc), do: acc + 0.0

  @doc false
  def reducer(batch) when is_list(batch) do
    batch
    |> Enum.reduce(0.0, &reducer/2)    
  end

  @doc ~S"""
  
  Applies the business rules to calls in the initial portion of time.

  Based on the business rules, which implies that for an arbitrary initial period the billing is 
  different, this function contains the rules for the initial period of each call. It is recursive on durations
  lower than the duration of the rule. And leaves after the minutes == factor
  is reached, leaving for the rules applied in `Calculator.Billage.remainer/3`.

  For example, for a 5 minute rule with 300 seconds duration.
  
  ## Examples
    
      iex> Calculator.Billage.first({300, 5, 5})
      {25, 0}
      iex> Calculator.Billage.first({330, 5, 5})
      {25, 30} # 30 seconds remaining

  """
  def first({duration, factor, value}, acc \\ 0, minute \\ 0) do
    cond do
      duration_lower_or_equal_than_0?(duration) -> {acc, duration}
      duration_greater_than_factor?(duration, factor) and minute == 0 -> {acc + factor * value, duration - factor * 60}
      minute_limit_reach?(minute, factor) -> {acc, duration}
      duration_lower_than_1min(duration) -> 
        first({0, factor, value}, acc + (value/60) * duration, minute + 1)
      true -> first({duration - 60, factor, value}, acc + value, minute + 1)
    end
  end

  @doc ~S"""
  
  Applies the business rules in the remainer time of the calls.

  For the ending period of the call, this function applies its rules and return the total value, it must be 
  called after `Calculator.Billage.first/3`.

  ## Examples
    
      # 1. Receives 5 minutes and a accumulated 25 cents with a factor of 1 which means it applies 2 cents per minute
      # 2. Receives an extra 30 seconds

      iex> Calculator.Billage.remainer({25, 300}, 1, 2) # 1.
      35.0
      iex> Calculator.Billage.remainer({25, 330}, 1, 2) # 2.
      36.0
  """
  def remainer({acc, duration}, factor, value) do
    cond do
      duration_lower_or_equal_than_0?(duration) -> acc
      duration_greater_than_factor?(duration, factor) ->
        bill = acc + factor * value
        remainer({bill, duration - 60}, factor, value)
      true -> acc + factor * (value/60) * duration
    end  
  end

  @doc """
  Calculates the time duration of the calls in seconds.
  """
  def calculate_time({:ok, record}) do
    {:ok, 
      %{duration: Time.diff(record.end_time, record.start_time), record: record}}
  end

  @doc false
  def calculate_time({:error, _record, _reason} = error), do: error

  @doc """
  Scans for the record with the highest duration.
  """
  def scan_for_the_highest(batch) when length(batch) > 1 do
    batch
    |> Enum.sort_by(fn {_, item} -> item.duration end)
    |> Enum.drop(-1)
  end

  @doc false
  def scan_for_the_highest(batch), do: batch 

  @doc """
  Batches the stream into an enumerable to be further used.
  """
  def prepare(batch), do: Enum.into(batch, [])  

  defp duration_lower_or_equal_than_0?(duration), do: duration <= 0
  defp duration_lower_than_1min(duration), do: duration < 60
  defp duration_greater_than_factor?(duration, factor), do: duration - factor * 60 > 0
  defp minute_limit_reach?(minute, factor), do: minute >= factor
end
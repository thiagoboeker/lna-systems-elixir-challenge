defmodule CalculatorTest do
  use ExUnit.Case, async: true
  alias Calculator

  setup do
    fullset = """
    09:11:00;09:15:22;+351914374373;+351215355312
    15:20:04;15:23:49;+351217538222;+351214434422
    16:43:02;16:50:20;+351217235554;+351329932233
    17:44:04;17:49:30;+351914374373;+351963433432
    """
    {:ok, [fullset: fullset]}
  end

  test "Calculator Run", context do
    set = String.split(context.fullset, "\n")
    
    # 21.84 + 18.75 + 29.61 + 25.87 = 96.07 - 29.61(highest)
    
    fullset = 
      Stream.take(set, 4)
      |> Calculator.compute()
    assert round(fullset) == 66

    # 4:22 ceiling -> minutes 5 * 4 + 1 * (5/60) * 22 = 21.83
    
    single = 
      Stream.take(set, 1)
      |> Calculator.compute()
    assert round(single) == 22

    # 5:26 minutes ceiling -> 5 * 5 + 1 * (2/60) * 26 = 25.87

    # greater_than_5 = 
    #   set
    #   |> Enum.drop(-1)
    #   |> Enum.reverse()
    #   |> Stream.take(1)
    #   |> Calculator.compute()
    # assert round(greater_than_5) == 26
      
  end
end

defmodule Calculator.ParserTest do
  use ExUnit.Case, async: true
  doctest Calculator.Parser
end 

defmodule Calculator.BillageTest do
  use ExUnit.Case, async: true
  doctest Calculator.Billage
end

defmodule Calculator.RecordTest do
  use ExUnit.Case, async: true
  doctest Calculator.Record
end

defmodule Calculator.SanitizerTest do
  use ExUnit.Case, async: true
  doctest Calculator.Sanitizer
end

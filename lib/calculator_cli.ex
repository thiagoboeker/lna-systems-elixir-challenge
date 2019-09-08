defmodule Calculator.Cli do
  @moduledoc false

  def main(argv) do
    argv
    |> parse_args()
    |> run()
  end

  defp parse_args(argv) do
    args = OptionParser.parse(argv, strict: [help: :boolean])

    case args do
      {[help: true]} -> :help
      {_, [path], _} -> path
      _ -> :help
    end
  end

  defp run(:help) do
    IO.puts("""    
    # Instructions
    
    Inside the project directory run \"lna_systems path_to_file\" to run the application
    
    Run \"mix escript.build\" to build the executable
    
    # Usage
    
    ./lna_systems path/to/file
    """
    )
  end

  defp run(path) do
    File.stream!(path)
    |> Calculator.run()
  end
end

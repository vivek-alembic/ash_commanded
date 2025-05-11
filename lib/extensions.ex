defmodule AshCommanded.Extensions do
  @moduledoc """
  Extension registration for AshCommanded.
  """

  use Spark.Dsl.Extension

  @doc false
  def extensions do
    [
      AshCommanded.Commanded.Dsl
    ]
  end
end
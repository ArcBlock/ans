defmodule Edns.Cache do
  @moduledoc """
  Definition for edns cache test.
  """

  use Mcc.Model

  import_table(Edns.Handler.Cache.Exp)
  import_table(Edns.Handler.Cache)

  # __end_of_module__
end

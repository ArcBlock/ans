use Mix.Config

config :mcc,
  mnesia_table_modules: [Ansc.Cache, Edns.Cache]

import_config "../apps/*/config/config.exs"

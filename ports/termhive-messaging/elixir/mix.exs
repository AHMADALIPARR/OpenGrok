# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
defmodule TermHive.MixProject do
  use Mix.Project
  def project do
    [
      app: :termhive,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: TermHive.CLI],
      deps: []
    ]
  end
  def application do
    [extra_applications: [:logger]]
  end
end

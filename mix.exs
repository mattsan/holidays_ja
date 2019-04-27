defmodule HolidaysJa.MixProject do
  use Mix.Project

  def project do
    [
      app: :holidays_ja,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:iconv, "~> 1.0"},
      {:httpoison, "~> 1.5"},
      {:csv, "~> 2.3"}
    ]
  end
end

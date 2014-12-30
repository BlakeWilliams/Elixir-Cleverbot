defmodule Cleverbot.Mixfile do
  use Mix.Project

  def project do
    [app: :cleverbot,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps,
     source_url: "https://github.com/BlakeWilliams/Elixir-Cleverbot",
     description: "A Cleverbot API wrapper.",
     package: package]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:httpoison, "~> 0.5.0"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.6", only: :dev}]
  end

  defp package do
    %{contributors: ["Blake Williams"],
      licenses: ["MIT"],
      links: %{
        "Github": "https://github.com/BlakeWilliams/Elixir-Cleverbot",
        "Documentation": "http://hexdocs.pm/cleverbot/"
      }}
  end
end

# Cleverbot

A simple Cleverbot API implmentation in Elixir that supports `think`
converstations.

## Usage

Add Cleverbot to your `mix.exs` dependencies.

```elixir
def deps do
  [{:cleverbot, git: "https://github.com/BlakeWilliams/Elixir-Cleverbot"}]
end
```

Then create a new `Cleverbot` and `think`!

```elixir
{:ok, pid} = Cleverbot.start_link

Cleverbot.think(pid, "Hello!") |> IO.puts
```

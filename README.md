# Cleverbot

A simple [Cleverbot] API implmentation in Elixir that supports `think`
converstations.

[Cleverbot]: http://www.cleverbot.com/

## Usage

Add Cleverbot to your `mix.exs` dependencies.

```elixir
def deps do
  [{:cleverbot, "~> 0.0.1"}]
end
```

Then create a new `Cleverbot` and `think`!

```elixir
{:ok, pid} = Cleverbot.start_link

Cleverbot.think(pid, "Hello!") |> IO.puts
```

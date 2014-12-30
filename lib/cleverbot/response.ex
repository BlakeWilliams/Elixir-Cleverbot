defmodule Cleverbot.Response do
  @moduledoc false
  def parse(response) do
    lines = String.split(response, "\r")

    %{
      text: Enum.at(lines, 0),
      session_id: Enum.at(lines, 1)
    }
  end
end

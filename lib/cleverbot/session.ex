defmodule Cleverbot.Session do
  @moduledoc """
  A struct that holds the state of a cleverbot session consisting of
  `session_id` and `history`.
  """
  defstruct session_id: nil, history: []
  @type session :: %__MODULE__{session_id: binary | nil, history: [] | [binary]}

  @doc """
  Updates a `Cleverbot.Session`'s history and session_id to reflect the latest
  response and message.
  """
  @spec update(session, binary, binary) :: session
  def update(session, message, response) do
    new_history = session.history
                  |> List.insert_at(0, message)
                  |> List.insert_at(0, response.text)
                  |> Enum.slice(0, 10)

    %{session | session_id: response.session_id, history: new_history}
  end
end

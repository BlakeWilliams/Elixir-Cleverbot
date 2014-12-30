defmodule Cleverbot do
  @moduledoc """
  A genserver implementation of the Cleverbot API to hold conversations with 
  [Cleverbot].

  [Cleverbot]: http://www.cleverbot.com/

  ## Example

  ```
  {:ok, pid} = Cleverbot.start_link
  Cleverbot.think(pid, "Hello, Cleverbot!")

  session = Cleverbot.get_session(pid)
  IO.puts List.first(session.history)
  ```
  """

  use GenServer
  @url "http://www.cleverbot.com/webservicemin"

  @doc """
  Starts a Cleverbot process. You can pass in an existing `Cleverbot.Session`
  as the first argument.
  """
  def start_link(session \\ %Cleverbot.Session{}, http \\ HTTPoison) do
    GenServer.start_link(__MODULE__, %{session: session, http: http})
  end

  @doc """
  Sends the given message to the Cleverbot process and returns Cleverbot's
  reply.
  """
  def think(pid, message) do
    GenServer.call(pid, {:think, message}, 15000)
  end

  @doc """
  Retreive the current `Cleverbot.Session`.
  """
  def get_session(pid) do
    GenServer.call(pid, :value)
  end

  # GenServer

  @doc false
  def init(session) do
    {:ok, session}
  end

  @doc false
  def handle_call(:value, _from, state = %{session: session}) do
    {:reply, session, state}
  end

  @doc false
  def handle_call({:think, message}, _from, state = %{session: session, http: http}) do
    response = think_about_it(message, session, http)
    new_session = Cleverbot.Session.update(session, message, response)

    state = Map.put(state, :session, new_session)

    {:reply, response.text, state}
  end

  defp think_about_it(message, session, http) do
    form_data = build_query(message, session)
    {:ok, response} = http.post(@url, form_data, headers)

    Cleverbot.Response.parse(response.body)
  end

  defp headers do
    %{
      "Cache-Control" => "no-cache, no-cache",
      "Pragma" => "no-cache",
      "Referer" => "http://www.cleverbot.com"
    }
  end

  defp build_query(message, session) do
    initial_data = build_form_map(message, session)
    icognocheck = URI.encode_query(initial_data)
                  |> String.slice(9..34)
                  |> md5

    List.insert_at(initial_data, 11, {:icognocheck, icognocheck})
    initial_data ++ [icognocheck: icognocheck] |> URI.encode_query
  end

  defp build_form_map(message, session) do
    [
      stimulus: URI.encode(message),
      start: "y",
      sessionid: session.session_id,
      vText8: Enum.at(session.history, 6),
      vText7: Enum.at(session.history, 5),
      vText6: Enum.at(session.history, 4),
      vText5: Enum.at(session.history, 3),
      vText4: Enum.at(session.history, 2),
      vText3: Enum.at(session.history, 1),
      vText2: Enum.at(session.history, 0),
      icognoid: "wsf",
      fno: 0,
      sub: "Say",
      islearning: 1,
      cleanslate: false,
    ]
  end

  defp md5(string) do
    :crypto.hash(:md5, string)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
    |> List.flatten
    |> :erlang.list_to_bitstring
    |> to_string
  end
end

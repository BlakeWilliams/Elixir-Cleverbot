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
  @url "http://www.cleverbot.com/webservicemin?uc=165&"

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
    {:ok, response} = http.post(@url, {:form, form_data}, headers)

    Cleverbot.Response.parse(response.body)
  end

  defp headers do
    %{
        "User-Agent" => "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
        "Accept-Language" => "en-us,en;q=0.8,en-us;q=0.5,en;q=0.3",
        "Cache-Control" => "no-cache",
        "Cookie" => "XVIS=TEI939AFFIAGAYQZ",
        "Host" => "www.cleverbot.com",
        "Referer" => "http://www.cleverbot.com/",
        "Pragma" => "no-cache"
    }
  end

  defp build_query(message, session) do
    initial_data = build_form_map(message, session)
    icognocheck = URI.encode_query(initial_data)
                  |> String.slice(9..34)
                  |> md5

    Keyword.put(initial_data, :icognocheck, icognocheck)
  end

  defp build_form_map(message, session) do
    # taken from https://github.com/folz/cleverbot.py
    [
      stimulus: URI.encode(message, &URI.char_unreserved?/1),
      cb_settings_language: "",
      cb_settings_scripting: "no",
      islearning: 1,  # Never modified
      icognoid: "wsf",  # Never modified
      icognocheck: "",
      
      start: "y",   # Never modified
      sessionid: session.session_id,
      vText8: Enum.at(session.history, 6),
      vText7: Enum.at(session.history, 5),
      vText6: Enum.at(session.history, 4),
      vText5: Enum.at(session.history, 3),
      vText4: Enum.at(session.history, 2),
      vText3: Enum.at(session.history, 1),
      vText2: Enum.at(session.history, 0),
      fno: 0,   # Never modified
      prevref: "",
      emotionaloutput: "",  # Never modified
      emotionalhistory: "",  # Never modified
      asbotname: "",  # Never modified
      ttsvoice: "",  # Never modified 
      typing: "",  # Never modified
      lineref: "",
      sub: "Say",  # Never modified
      cleanslate: "false"  # Never modified
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

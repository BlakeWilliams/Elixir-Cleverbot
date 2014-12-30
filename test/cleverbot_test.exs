defmodule CleverbotTest do
  use ExUnit.Case

  test "start_link starts with an empty session" do
    {:ok, pid} = Cleverbot.start_link()

    assert Cleverbot.get_session(pid) == %Cleverbot.Session{}
  end

  test "think returns replies" do
    session = %Cleverbot.Session{}
    {:ok, pid} = Cleverbot.start_link(session, __MODULE__.FakeHTTP)

    assert Cleverbot.think(pid, "Hi !") == "Hello!"
  end

  test "it updates the session" do
    session = %Cleverbot.Session{}
    {:ok, pid} = Cleverbot.start_link(session, __MODULE__.FakeHTTP)

    Cleverbot.think(pid, "Hi !")

    assert length(Cleverbot.get_session(pid).history) == 2
  end

  defmodule FakeHTTP do
    def post(url, form_data, _headers) do
      ^url = "http://www.cleverbot.com/webservicemin"
      data = URI.decode_query(form_data)

      icognocheck = Map.get(data, "icognocheck")
      ^icognocheck = "cae1ea8e14fb894f30b143f106f0f636"

      stimulus = Map.get(data, "stimulus")
      ^stimulus = "Hi%20!"

      {:ok, %{body: "Hello!\r1"}}
    end
  end
end

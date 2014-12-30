defmodule Cleverbot.SessionTest do
  use ExUnit.Case

  test "update appends to history and updates session id" do
    session = %Cleverbot.Session{}
    response = %{session_id: 1, text: "Hello!"}

    new_session = Cleverbot.Session.update(session, "Hi!", response)

    assert new_session.history == ["Hello!", "Hi!"]
    assert new_session.session_id == 1
  end

  test "it removes history after 10 entries" do
    session = %Cleverbot.Session{history: [1,2,3,4,5,6,7,8,9,10]}
    response = %{session_id: 1, text: "Hello!"}

    new_session = Cleverbot.Session.update(session, "Hi!", response)

    assert length(new_session.history) == 10
    assert List.first(new_session.history) == "Hello!"
    assert List.last(new_session.history) == 8
  end
end

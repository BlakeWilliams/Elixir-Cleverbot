defmodule Cleverbot.ReponseTest do
  use ExUnit.Case

  test "parse returns text and session id" do
    expected = %{text: "foo", session_id: "123"}
    assert Cleverbot.Response.parse("foo\r123") == expected
  end
end

defmodule SportywebWeb.PageControllerTest do
  use SportywebWeb.ConnCase

  import Sportyweb.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "GET /" do
    test "User is logged out", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Sportverein"
    end

    test "User is logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user)
      conn = get(conn, ~p"/")
      assert redirected_to(conn, 302) =~ "/clubs"
    end
  end
end

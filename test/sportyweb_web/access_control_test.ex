defmodule SportywebWeb.AccessControlTest do
  use SportywebWeb.ConnCase, async: true

  alias SportywebWeb.AccessControl
  import Sportyweb.AccountsFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, SportywebWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{super_user: user_fixture_super_user(), customer: user_fixture_customer(), conn: conn}
  end

  describe "require_super_user/1" do
    test "redirects if user is not super user", %{conn: conn, customer: user} do
      conn = conn |> assign(:current_user, user)  |> AccessControl.require_super_user([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/"

    end

    test "does not redirect if user is super user", %{conn: conn, super_user: user} do
      conn = conn |> assign(:current_user, user) |> AccessControl.require_super_user([])

      refute conn.halted
      refute conn.status
    end
  end

end

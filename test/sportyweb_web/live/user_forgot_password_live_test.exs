defmodule SportywebWeb.UserForgotPasswordLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures

  alias Sportyweb.Accounts
  alias Sportyweb.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/users/reset_password")

      assert html =~ "Passwort vergessen?"
      assert has_element?(lv, ~s|a[href="#{~p"/users/register"}"]|, "Registrieren")
      assert has_element?(lv, ~s|a[href="#{~p"/users/log_in"}"]|, "Anmelden")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{user: user_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => user.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Wenn sich Ihre E-Mail-Adresse in unserem System befindet"

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      user_fixture(%{email: "timing_attack_dummy@sportyweb.de"})

      {:ok, conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Wenn sich Ihre E-Mail-Adresse in unserem System befindet"
      assert Accounts.UserToken |> Repo.all() |> Enum.count() == 1
    end

    test "clear dummy tokens", %{conn: conn} do

      valid_user = user_fixture()
      user_fixture(%{email: "timing_attack_dummy@sportyweb.de"})

      # set token for valid_user
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => valid_user.email})
        |> render_submit()
        |> follow_redirect(conn, "/")


      # generate and delete dummy tokens only
      Enum.map(1..250, fn _x ->

        # Uncomment to see token counts per run
        # count = Accounts.UserToken |> Repo.all() |> Enum.count()
        # IO.inspect("run #{x}, count: #{count}")

        {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

        {:ok, conn} =
          lv
          |> form("#reset_password_form", user: %{"email" => "unknown@example.com"})
          |> render_submit()
          |> follow_redirect(conn, "/")

        assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Wenn sich Ihre E-Mail-Adresse in unserem System befindet"
        assert Accounts.UserToken |> Repo.all() |> Enum.count() > 0

        end
      )

      assert Accounts.UserToken |> Repo.all() |> Enum.count() < 200

    end
  end
end

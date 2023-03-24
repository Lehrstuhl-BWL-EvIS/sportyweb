defmodule SportywebWeb.UserResetPasswordLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures

  alias Sportyweb.Accounts

  setup do
    user = user_fixture()

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_reset_password_instructions(user, url)
      end)

    %{token: token, user: user}
  end

  describe "Reset password page" do
    test "renders reset password with valid token", %{conn: conn, token: token} do
      {:ok, _lv, html} = live(conn, ~p"/users/reset_password/#{token}")

      assert html =~ "Passwort ändern"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      {:error, {:redirect, to}} = live(conn, ~p"/users/reset_password/invalid")

      assert to == %{
               flash: %{"error" => "Der Link zum Ändern des Passworts ist falsch oder abgelaufen."},
               to: ~p"/"
             }
    end

    test "renders errors for invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      result =
        lv
        |> element("#reset_password_form")
        |> render_change(
          user: %{"password" => "secret", "confirmation_password" => "secret123456"}
        )

      assert result =~ "Muss mindestens 8-Zeichen lang sein."
      assert result =~ "Passwörter stimmen nicht überein."
    end
  end

  describe "Reset Password" do
    test "resets password once", %{conn: conn, token: token, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      {:ok, conn} =
        lv
        |> form("#reset_password_form",
          user: %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/log_in")

      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password erfolreich geändert."
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      result =
        lv
        |> form("#reset_password_form",
          user: %{
            "password" => "too sh",
            "password_confirmation" => "does not match"
          }
        )
        |> render_submit()

      assert result =~ "Passwort ändern"
      assert result =~ "Muss mindestens 8-Zeichen lang sein."
      assert result =~ "Passwörter stimmen nicht überein."
    end
  end

  describe "Reset password navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      {:ok, _log_in_live, log_in_html} =
        lv
        |> element(~s|main a:fl-contains("Anmelden")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert log_in_html =~ "Anmelden"
    end

    test "redirects to password reset page when the Register button is clicked", %{
      conn: conn,
      token: token
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

      {:ok, _register_live, register_html} =
        lv
        |> element(~s|main a:fl-contains("Registrieren")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/register")

      assert register_html =~ "Ein Konto erstellen"
    end
  end
end

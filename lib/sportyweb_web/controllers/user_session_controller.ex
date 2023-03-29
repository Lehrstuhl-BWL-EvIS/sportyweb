defmodule SportywebWeb.UserSessionController do
  use SportywebWeb, :controller

  alias Sportyweb.Accounts
  alias SportywebWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Konto erfolgreich erstellt!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Passwort erfolgreich aktualisiert!")
  end

  def create(conn, params) do
    create(conn, params, "Willkommen zurück!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Ungültige E-Mail oder ungültiges Passwort.")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Erfolgreich abgemeldet.")
    |> UserAuth.log_out_user()
  end







end

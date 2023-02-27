defmodule Sportyweb.Accounts.UserNotifier do
  import Swoosh.Email

  alias Sportyweb.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Sportyweb", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Bestätigungsanweisungen", """

    ==============================

    Hallo #{user.email},

    Sie können Ihr Konto bestätigen, indem Sie die folgende URL besuchen:

    #{url}

    Wenn Sie kein Konto bei uns erstellt haben, ignorieren Sie dies bitte.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Anweisungen zum Zurücksetzen des Passworts", """

    ==============================

    Hallo #{user.email},

    Sie können Ihr Passwort zurücksetzen, indem Sie die folgende URL besuchen:

    #{url}

    Wenn Sie diese Änderung nicht angefordert haben, ignorieren Sie dies bitte.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "E-Mail-Anweisungen aktualisieren", """

    ==============================

    Hallo #{user.email},

    Sie können Ihre E-Mail ändern, indem Sie die folgende URL besuchen:

    #{url}

    Wenn Sie diese Änderung nicht angefordert haben, ignorieren Sie dies bitte.

    ==============================
    """)
  end

  @doc """
  Deliver information of being added to a club.
  """
  def deliver_info_of_being_added_to_club(user, club, url, pw) do
    deliver(user.email, "Sie wurden dem Verein #{club.name} auf Sportyweb hinzugefügt", """

    ==============================

    Hallo #{user.email},

    Sie können sich in Ihr Konto einloggen, indem Sie die folgende URL besuchen:

    #{url}

    Wir haben ein erstes Passwort für Sie erstellt. Bitte stellen Sie sicher, dass Sie es bei Ihrer ersten Anmeldung ändern.

    #{pw}

    Wenn Sie die Erstellung eines Kontos bei uns nicht beantragt haben, ignorieren Sie dies bitte.

    ==============================
    """)
  end
end

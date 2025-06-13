defmodule Sportyweb.Accounts.UserNotifier do

  alias Sportyweb.Mailer

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    Mailer.deliver_system_notification(user.email, "Bestätigungsanweisungen", """

    Hallo #{user.email},

    Sie können Ihr Konto bestätigen, indem Sie die folgende URL besuchen:

    #{url}

    Wenn Sie kein Konto bei uns erstellt haben, ignorieren Sie dies bitte.
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    Mailer.deliver_system_notification(user.email, "Anweisungen zum Zurücksetzen des Passworts", """

    Hallo #{user.email},

    Sie können Ihr Passwort zurücksetzen, indem Sie die folgende URL besuchen:

    #{url}

    Wenn Sie diese Änderung nicht angefordert haben, ignorieren Sie dies bitte.
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    Mailer.deliver_system_notification(user.email, "E-Mail-Anweisungen aktualisieren", """

    Hallo #{user.email},

    Sie können Ihre E-Mail ändern, indem Sie die folgende URL besuchen:

    #{url}

    Wenn Sie diese Änderung nicht angefordert haben, ignorieren Sie dies bitte.
    """)
  end

  @doc """
  Deliver information of being added to a club.
  """
  def deliver_info_of_being_added_to_club(user, club, url) do
    Mailer.deliver_system_notification(user.email, "Sie wurden dem Verein #{club.name} auf Sportyweb hinzugefügt", """

    Hallo #{user.email},

    Sie können Ihr Passwort festlegen, indem Sie die folgende URL besuchen:

    #{url}

    Wenn Sie die Erstellung eines Kontos bei uns nicht beantragt haben, ignorieren Sie dies bitte.
    """)
  end
end

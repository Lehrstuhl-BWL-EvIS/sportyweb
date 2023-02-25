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
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver information of being added to a club.
  """
  def deliver_info_of_being_added_to_club(user, club, url, pw) do
    deliver(user.email, "You have been added to club #{club.name} on Sportyweb", """

    ==============================

    Hi #{user.email},

    You have been added to club #{club.name} on Sportyweb.
    You can log in to your account by visiting the URL below:

    #{url}

    We have created an initial password for you. Please make sure to change it on your first log in.

    #{pw}

    If you didn't request to having an account created with us, please ignore this.

    ==============================
    """)
  end
end

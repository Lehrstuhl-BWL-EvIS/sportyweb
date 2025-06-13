defmodule Sportyweb.Mailer do
  use Swoosh.Mailer, otp_app: :sportyweb

  import Swoosh.Email

  # Delivers the email using the application mailer.
  def deliver_system_notification(recipient, subject, body) do
    escaped_body = """

        ==============================

        #{body}

        ==============================
    """

    email =
      new()
      |> to(recipient)
      |> from({"Sportyweb", "noreply@example.com"})
      |> subject(subject)
      |> text_body(escaped_body)

    with {:ok, _metadata} <- deliver(email) do
      {:ok, email}
    end
  end
end

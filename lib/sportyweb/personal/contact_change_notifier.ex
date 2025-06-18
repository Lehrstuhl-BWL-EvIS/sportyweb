defmodule Sportyweb.Person.ContactChangeNotifier do
  alias Sportyweb.Mailer
  alias Sportyweb.Personal.Contact

  def deliver_membership_state_change(%Contact{} = contact, message) do
    email = contact.email

    if email == "" do
      raise "no e-mail known of #{contact.name}"
    end

    Mailer.deliver_system_notification(email, "Status der Mitgliedschaft geändert", """
    Hallo #{contact.name},

    #{message}
    """)
  end
end

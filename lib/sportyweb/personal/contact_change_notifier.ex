defmodule Sportyweb.Person.ContactChangeNotifier do
  alias Sportyweb.Mailer
  alias Sportyweb.Personal.Contact

  def deliver_membership_state_change(contact, message) do
    email = Contact.get_most_relevant_email(contact).address

    Mailer.deliver_system_notification(email, "Status der Mitgliedschaft geändert", """
    Hallo #{contact.name},

    #{message}
    """)
  end
end

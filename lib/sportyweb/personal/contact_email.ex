defmodule Sportyweb.Personal.ContactEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_emails" do
    belongs_to :contact, Contact
    belongs_to :email, Email

    timestamps()
  end

  @doc false
  def changeset(contact_email, attrs) do
    contact_email
    |> cast(attrs, [:contact_id, :email_id])
    |> validate_required([:contact_id, :email_id])
    |> unique_constraint(:email_id, name: "contact_emails_email_id_index")
  end
end

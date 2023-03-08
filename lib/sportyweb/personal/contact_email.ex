defmodule Sportyweb.Personal.ContactEmail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_emails" do

    field :contact_id, :binary_id
    field :email_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact_email, attrs) do
    contact_email
    |> cast(attrs, [])
    |> validate_required([])
  end
end

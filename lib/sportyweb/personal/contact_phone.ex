defmodule Sportyweb.Personal.ContactPhone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_phones" do

    field :contact_id, :binary_id
    field :phone_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact_phone, attrs) do
    contact_phone
    |> cast(attrs, [])
    |> validate_required([])
  end
end

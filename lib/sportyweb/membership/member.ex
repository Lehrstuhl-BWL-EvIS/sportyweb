defmodule Sportyweb.Membership.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "members" do
    field :date_of_birth, :date
    field :email1, :string
    field :email2, :string
    field :firstname, :string
    field :gender, :string
    field :is_active, :boolean, default: false
    field :lastname, :string
    field :phone1, :string
    field :phone2, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:firstname, :lastname, :gender, :date_of_birth, :email1, :email2, :phone1, :phone2, :is_active])
    |> validate_required([:firstname, :lastname, :gender, :date_of_birth, :email1, :email2, :phone1, :phone2, :is_active])
  end
end

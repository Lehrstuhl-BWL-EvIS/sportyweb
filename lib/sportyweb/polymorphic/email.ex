defmodule Sportyweb.Polymorphic.Email do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "emails" do
    field :address, :string
    field :is_main, :boolean, default: false
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:type, :address, :is_main])
    |> validate_required([:type, :address, :is_main])
  end
end

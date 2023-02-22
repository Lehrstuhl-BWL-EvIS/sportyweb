defmodule Sportyweb.Polymorphic.Phone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "phones" do
    field :is_main, :boolean, default: false
    field :number, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(phone, attrs) do
    phone
    |> cast(attrs, [:type, :number, :is_main])
    |> validate_required([:type, :number, :is_main])
  end
end

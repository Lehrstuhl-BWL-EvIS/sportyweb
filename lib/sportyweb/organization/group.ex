defmodule Sportyweb.Organization.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "groups" do
    field :created_at, :date
    field :description, :string
    field :name, :string
    field :reference_number, :string
    field :department_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :reference_number, :description, :created_at])
    |> validate_required([:name, :reference_number, :description, :created_at])
  end
end

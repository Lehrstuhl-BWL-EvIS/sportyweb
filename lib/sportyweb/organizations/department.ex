defmodule Sportyweb.Organizations.Department do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departments" do
    field :created_at, :date
    field :name, :string
    field :type, :string
    field :club_id, :binary_id
    field :parent_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:name, :type, :created_at])
    |> validate_required([:name, :type, :created_at])
  end
end

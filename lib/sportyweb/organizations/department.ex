defmodule Sportyweb.Organizations.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organizations.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departments" do
    belongs_to :club, Club
    field :parent_id, :binary_id # TODO: Self-reference
    field :name, :string
    field :type, :string
    field :created_at, :date

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:name, :type, :created_at])
    |> validate_required([:name, :created_at])
    |> validate_length(:name, max: 250)
    |> validate_length(:type, max: 250)
  end
end

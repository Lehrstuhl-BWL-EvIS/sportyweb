defmodule Sportyweb.Organization.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departments" do
    field :name, :string
    field :type, :string
    field :created_at, :date
    belongs_to :club, Club
    belongs_to :parent, Department

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:name, :type, :created_at, :club_id], empty_values: [])
    |> validate_required([:name, :created_at, :club_id])
    |> validate_length(:name, max: 250)
    |> validate_length(:type, max: 250)
  end
end

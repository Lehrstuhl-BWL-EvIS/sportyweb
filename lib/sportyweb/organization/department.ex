defmodule Sportyweb.Organization.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departments" do
    belongs_to :club, Club
    belongs_to :parent, Department
    has_many :groups, Group, on_delete: :delete_all

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :created_at, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [
      :club_id,
      :name,
      :reference_number,
      :description,
      :created_at
      ], empty_values: ["", nil])
    |> validate_required([:club_id, :name, :created_at])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
  end
end

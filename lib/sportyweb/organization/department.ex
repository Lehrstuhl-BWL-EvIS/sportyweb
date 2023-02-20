defmodule Sportyweb.Organization.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.DepartmentNote
  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departments" do
    belongs_to :club, Club
    has_many :groups, Group, on_delete: :delete_all
    many_to_many :notes, Note, join_through: DepartmentNote

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
    |> cast_assoc(:notes, required: false)
    |> validate_required([:club_id, :name, :created_at])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> unique_constraint(
      :name,
      name: "departments_club_id_name_index",
      message: "Name bereits vergeben!")
  end
end

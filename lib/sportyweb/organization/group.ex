defmodule Sportyweb.Organization.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Department

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "groups" do
    belongs_to :department, Department

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :created_at, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :department_id,
      :name,
      :reference_number,
      :description,
      :created_at
      ], empty_values: ["", nil])
    |> validate_required([:department_id, :name, :created_at])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
  end
end

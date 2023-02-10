defmodule Sportyweb.RBAC.Role.ClubRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clubroles" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(club_role, attrs) do
    club_role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

defmodule Sportyweb.Organization.ClubPhone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_phones" do

    field :club_id, :binary_id
    field :phone_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(club_phone, attrs) do
    club_phone
    |> cast(attrs, [])
    |> validate_required([])
  end
end

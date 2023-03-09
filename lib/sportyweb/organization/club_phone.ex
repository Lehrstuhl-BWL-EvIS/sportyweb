defmodule Sportyweb.Organization.ClubPhone do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_phones" do
    belongs_to :club, Club
    belongs_to :phone, Phone

    timestamps()
  end

  @doc false
  def changeset(club_phone, attrs) do
    club_phone
    |> cast(attrs, [:club_id, :phone_id])
    |> validate_required([:club_id, :phone_id])
    |> unique_constraint(:phone_id, name: "club_phones_phone_id_index")
  end
end

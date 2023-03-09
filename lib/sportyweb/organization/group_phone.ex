defmodule Sportyweb.Organization.GroupPhone do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_phones" do
    belongs_to :group, Group
    belongs_to :phone, Phone

    timestamps()
  end

  @doc false
  def changeset(group_phone, attrs) do
    group_phone
    |> cast(attrs, [:group_id, :phone_id])
    |> validate_required([:group_id, :phone_id])
    |> unique_constraint(:phone_id, name: "group_phones_phone_id_index")
  end
end

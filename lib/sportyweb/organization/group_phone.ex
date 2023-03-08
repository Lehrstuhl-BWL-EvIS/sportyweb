defmodule Sportyweb.Organization.GroupPhone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_phones" do

    field :group_id, :binary_id
    field :phone_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(group_phone, attrs) do
    group_phone
    |> cast(attrs, [])
    |> validate_required([])
  end
end

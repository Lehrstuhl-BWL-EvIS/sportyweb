defmodule Sportyweb.Calendar.EventGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_groups" do

    field :event_id, :binary_id
    field :group_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_group, attrs) do
    event_group
    |> cast(attrs, [])
    |> validate_required([])
  end
end

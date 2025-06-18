defmodule Sportyweb.History.Change do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "changes" do
    belongs_to :club, Club
    field :entity_id, :binary
    field :entity_type, :string
    field :attribute, :string
    field :new_value, :string
    field :changed_by, :string
    field :changed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(change, attrs) do
    change
    |> cast(
      attrs,
      [
        :entity_type,
        :entity_id,
        :changed_by,
        :changed_at,
        :attribute,
        :new_value,
        :club_id
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :entity_type,
      :entity_id,
      :changed_by,
      :changed_at,
      :attribute,
      :club_id
    ])
  end
end

defmodule Sportyweb.Polymorphic.Note do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notes" do
    field :value, :string, default: ""

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:value], empty_values: ["", nil])
    |> validate_required([:value])
    |> validate_length(:value, max: 20_000)
  end
end

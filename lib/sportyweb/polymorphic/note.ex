defmodule Sportyweb.Polymorphic.Note do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notes" do
    field :content, :string, default: ""

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:content], empty_values: ["", nil])
    |> validate_required([])
    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, max: 20_000)
  end
end

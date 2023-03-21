defmodule Sportyweb.Polymorphic.Note do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notes" do
    field :content, :string, default: ""
    field :delete, :boolean, default: false, virtual: true

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:content, :delete], empty_values: ["", nil])
    |> validate_required([])
    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, max: 20_000)
    |> set_action()
  end

  defp set_action(%{data: %{:id => id}} = changeset) do
    # The delete value has to come from the current changeset
    delete = get_change(changeset, :delete)

    case {id, delete} do
      {nil, true} -> %{changeset | action: :ignore}
      {nil, _}    -> %{changeset | action: :insert}
      {_, true}   -> %{changeset | action: :delete}
      {_, _}      -> %{changeset | action: :update}
    end
  end
end

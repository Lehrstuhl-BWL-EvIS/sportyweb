defmodule Sportyweb.Polymorphic.InternalEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "internal_events" do
    field :archive_date, :date
    field :commission_date, :date
    field :frequency, :string
    field :interval, :integer
    field :is_recurring, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(internal_event, attrs) do
    internal_event
    |> cast(attrs, [:is_recurring, :commission_date, :archive_date, :frequency, :interval])
    |> validate_required([:is_recurring, :commission_date, :archive_date, :frequency, :interval])
  end
end

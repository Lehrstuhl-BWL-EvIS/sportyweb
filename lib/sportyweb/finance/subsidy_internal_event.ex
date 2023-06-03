defmodule Sportyweb.Finance.SubsidyInternalEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subsidy_internal_events" do

    field :subsidy_id, :binary_id
    field :internal_event_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(subsidy_internal_event, attrs) do
    subsidy_internal_event
    |> cast(attrs, [])
    |> validate_required([])
  end
end

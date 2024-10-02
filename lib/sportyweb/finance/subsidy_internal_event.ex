defmodule Sportyweb.Finance.SubsidyInternalEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Polymorphic.InternalEvent

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subsidy_internal_events" do
    belongs_to :subsidy, Subsidy
    belongs_to :internal_event, InternalEvent

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subsidy_internal_event, attrs) do
    subsidy_internal_event
    |> cast(attrs, [:subsidy, :internal_event_id])
    |> validate_required([:subsidy, :internal_event_id])
    |> unique_constraint(:note_id, name: "subsidy_internal_events_internal_event_id_index")
  end
end

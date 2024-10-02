defmodule Sportyweb.Finance.FeeInternalEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Polymorphic.InternalEvent

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fee_internal_events" do
    belongs_to :fee, Fee
    belongs_to :internal_event, InternalEvent

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(fee_internal_event, attrs) do
    fee_internal_event
    |> cast(attrs, [:fee, :internal_event_id])
    |> validate_required([:fee, :internal_event_id])
    |> unique_constraint(:note_id, name: "fee_internal_events_internal_event_id_index")
  end
end

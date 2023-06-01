defmodule Sportyweb.Calendar.EventFee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Finance.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_fees" do
    belongs_to :event, Event
    belongs_to :fee, Fee

    timestamps()
  end

  @doc false
  def changeset(event_fee, attrs) do
    event_fee
    |> cast(attrs, [:event_id, :fee_id])
    |> validate_required([:event_id, :fee_id])
    |> unique_constraint(:fee_id, name: "event_fees_fee_id_index")
  end
end

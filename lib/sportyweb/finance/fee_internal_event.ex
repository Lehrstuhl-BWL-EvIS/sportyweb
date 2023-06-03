defmodule Sportyweb.Finance.FeeInternalEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fee_internal_events" do

    field :fee_id, :binary_id
    field :internal_event_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(fee_internal_event, attrs) do
    fee_internal_event
    |> cast(attrs, [])
    |> validate_required([])
  end
end

defmodule Sportyweb.Calendar.EventFee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_fees" do

    field :event_id, :binary_id
    field :fee_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_fee, attrs) do
    event_fee
    |> cast(attrs, [])
    |> validate_required([])
  end
end

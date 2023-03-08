defmodule Sportyweb.Calendar.EventEmail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_emails" do

    field :event_id, :binary_id
    field :email_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_email, attrs) do
    event_email
    |> cast(attrs, [])
    |> validate_required([])
  end
end

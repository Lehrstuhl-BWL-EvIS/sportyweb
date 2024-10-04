defmodule Sportyweb.Calendar.EventEmail do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_emails" do
    belongs_to :event, Event
    belongs_to :email, Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_email, attrs) do
    event_email
    |> cast(attrs, [:event_id, :email_id])
    |> validate_required([:event_id, :email_id])
    |> unique_constraint(:email_id, name: "event_emails_email_id_index")
  end
end

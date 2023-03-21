defmodule Sportyweb.Calendar.EventEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_emails" do
    belongs_to :event, Event
    belongs_to :email, Email

    timestamps()
  end

  @doc false
  def changeset(event_email, attrs) do
    event_email
    |> cast(attrs, [:event_id, :email_id])
    |> validate_required([:event_id, :email_id])
    |> unique_constraint(:email_id, name: "event_emails_email_id_index")
  end
end
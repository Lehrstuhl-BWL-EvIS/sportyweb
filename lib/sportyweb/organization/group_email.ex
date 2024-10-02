defmodule Sportyweb.Organization.GroupEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_emails" do
    belongs_to :group, Group
    belongs_to :email, Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group_email, attrs) do
    group_email
    |> cast(attrs, [:group_id, :email_id])
    |> validate_required([:group_id, :email_id])
    |> unique_constraint(:email_id, name: "group_emails_email_id_index")
  end
end

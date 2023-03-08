defmodule Sportyweb.Organization.GroupEmail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_emails" do

    field :group_id, :binary_id
    field :email_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(group_email, attrs) do
    group_email
    |> cast(attrs, [])
    |> validate_required([])
  end
end

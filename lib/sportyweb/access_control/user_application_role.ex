defmodule Sportyweb.AccessControl.UserApplicationRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Accounts.User
  alias Sportyweb.AccessControl.ApplicationRole

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "userapplicationroles" do
    belongs_to :user, User
    belongs_to :applicationrole, ApplicationRole

    timestamps()
  end

  @doc false
  def changeset(user_application_role, attrs) do
    user_application_role
    |> cast(attrs, [])
    |> validate_required([])
  end
end

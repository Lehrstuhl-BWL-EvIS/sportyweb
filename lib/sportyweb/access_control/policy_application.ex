defmodule Sportyweb.AccessControl.PolicyApplication do

  import Ecto.Query

  alias Sportyweb.Repo
  alias Sportyweb.Accounts.User

  #alias Sportyweb.AccessControl
  alias Sportyweb.AccessControl.UserApplicationRole, as: UAR
  alias Sportyweb.AccessControl.RolePermissionMatrix, as: RPM

  ### ROLE-PERMISSION-MATRIX ###
  def role_permission_matrix, do: RPM.role_permission_matrix(:application)

  def get_application_roles_all, do: Keyword.keys(role_permission_matrix()) |> Enum.map(&( Atom.to_string(&1)))

  def is_sportyweb_admin(%User{id: user_id}) do
    query = from uar in UAR,
      where: uar.user_id == ^user_id,
      join: ar in assoc(uar, :applicationrole),
      select: ar.name

      Enum.member?(Repo.all(query), "sportyweb_admin")
  end

end

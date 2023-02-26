defmodule Sportyweb.RBAC.UserRole do
  @moduledoc """
  The RBAC.UserRole context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.RBAC.UserRole.UserClubRole

  @doc """
  Returns the list of userclubroles.

  ## Examples

      iex> list_userclubroles()
      [%UserClubRole{}, ...]

  """
  def list_userclubroles do
    Repo.all(UserClubRole)
  end

  @doc """
  Returns list of userclubroles of the club.
  """
  def list_clubs_userclubroles(club_id) do
    query = from ucr in UserClubRole,
      where: ucr.club_id == ^club_id,
      join: u in assoc(ucr, :user),
      join: cr in assoc(ucr, :clubrole),
      preload: [user: u, clubrole: cr]

    Repo.all(query)
  end

  @doc """
  Returns list of userclubroles of the club.
  """

  def list_users_clubroles_in_a_club(user_id, club_id) do
    query = from ucr in UserClubRole,
      where: ucr.club_id == ^club_id,
      where: ucr.user_id == ^user_id,
      join: cr in assoc(ucr, :clubrole),
      preload: [clubrole: cr]

    Repo.all(query)
  end

  def list_users_in_a_club(club_id) do
    query = from ucr in UserClubRole,
      where: ucr.club_id == ^club_id,
      join: u in assoc(ucr, :user),
      preload: [user: u]

    Repo.all(query)
  end

  def list_users_clubroles_in_a_club_depr(userclubrole) do
    query = from ucr in UserClubRole,
      where: ucr.club_id == ^userclubrole.club_id,
      where: ucr.user_id == ^userclubrole.user_id,
      join: u in assoc(ucr, :user),
      join: cr in assoc(ucr, :clubrole),
      preload: [user: u, clubrole: cr]

    Repo.all(query)
  end

  @doc """
  Gets a single user_club_role.

  Raises `Ecto.NoResultsError` if the User club role does not exist.

  ## Examples

      iex> get_user_club_role!(123)
      %UserClubRole{}

      iex> get_user_club_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_club_role!(id), do: Repo.get!(UserClubRole, id)

  def get_user_club_role_preload(id) do
    query = from ucr in UserClubRole,
      where: ucr.id == ^id,
      join: u in assoc(ucr, :user),
      join: c in assoc(ucr, :club),
      join: cr in assoc(ucr, :clubrole),
      preload: [user: u, club: c, clubrole: cr]

    Repo.all(query)
  end

  @doc """
  Creates a user_club_role.

  ## Examples

      iex> create_user_club_role(%{field: value})
      {:ok, %UserClubRole{}}

      iex> create_user_club_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_user_club_role(attrs \\ %{}) do
    %UserClubRole{}
    |> UserClubRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_club_role.

  ## Examples

      iex> update_user_club_role(user_club_role, %{field: new_value})
      {:ok, %UserClubRole{}}

      iex> update_user_club_role(user_club_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_club_role(%UserClubRole{} = user_club_role, attrs) do
    user_club_role
    |> UserClubRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_club_role.

  ## Examples

      iex> delete_user_club_role(user_club_role)
      {:ok, %UserClubRole{}}

      iex> delete_user_club_role(user_club_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_club_role(%UserClubRole{} = user_club_role) do
    Repo.delete(user_club_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_club_role changes.

  ## Examples

      iex> change_user_club_role(user_club_role)
      %Ecto.Changeset{data: %UserClubRole{}}

  """
  def change_user_club_role(%UserClubRole{} = user_club_role, attrs \\ %{}) do
    UserClubRole.changeset(user_club_role, attrs)
  end

  alias Sportyweb.RBAC.UserRole.UserApplicationRole

  @doc """
  Returns the list of userapplicationroles.

  ## Examples

      iex> list_userapplicationroles()
      [%UserApplicationRole{}, ...]

  """
  def list_userapplicationroles do
    Repo.all(UserApplicationRole)
  end

  def list_users_applicationroles(user) do
    query = from uar in UserApplicationRole,
      where: uar.user_id == ^user.id,
      join: ar in assoc(uar, :applicationrole),
      preload: [applicationrole: ar]

    Repo.all(query)

  end

  @doc """
  Gets a single user_application_role.

  Raises `Ecto.NoResultsError` if the User application role does not exist.

  ## Examples

      iex> get_user_application_role!(123)
      %UserApplicationRole{}

      iex> get_user_application_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_application_role!(id), do: Repo.get!(UserApplicationRole, id)

  @doc """
  Creates a user_application_role.

  ## Examples

      iex> create_user_application_role(%{field: value})
      {:ok, %UserApplicationRole{}}

      iex> create_user_application_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_application_role(attrs \\ %{}) do
    %UserApplicationRole{}
    |> UserApplicationRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_application_role.

  ## Examples

      iex> update_user_application_role(user_application_role, %{field: new_value})
      {:ok, %UserApplicationRole{}}

      iex> update_user_application_role(user_application_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_application_role(%UserApplicationRole{} = user_application_role, attrs) do
    user_application_role
    |> UserApplicationRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_application_role.

  ## Examples

      iex> delete_user_application_role(user_application_role)
      {:ok, %UserApplicationRole{}}

      iex> delete_user_application_role(user_application_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_application_role(%UserApplicationRole{} = user_application_role) do
    Repo.delete(user_application_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_application_role changes.

  ## Examples

      iex> change_user_application_role(user_application_role)
      %Ecto.Changeset{data: %UserApplicationRole{}}

  """
  def change_user_application_role(%UserApplicationRole{} = user_application_role, attrs \\ %{}) do
    UserApplicationRole.changeset(user_application_role, attrs)
  end

  alias Sportyweb.RBAC.UserRole.UserDepartmentRole

  @doc """
  Returns the list of userdepartmentroles.

  ## Examples

      iex> list_userdepartmentroles()
      [%UserDepartmentRole{}, ...]

  """
  def list_userdepartmentroles do
    Repo.all(UserDepartmentRole)
  end

  @doc """
  Returns list of userclubroles of the club.
  """
  def list_userdepartmentroles_by_department (dept_id) do
    query = from udr in UserDepartmentRole,
      where: udr.department_id == ^dept_id,
      join: u in assoc(udr, :user),
      join: d in assoc(udr, :department),
      join: dr in assoc(udr, :departmentrole),
      preload: [user: u, department: d, departmentrole: dr]

    Repo.all(query)
  end

  @doc """
  Returns list of userclubroles of the club.
  """

  def list_users_departmentroles_in_a_department(user_id, dept_id) do
    query = from udr in UserDepartmentRole,
      where: udr.department_id == ^dept_id,
      where: udr.user_id == ^user_id,
      join: d in assoc(udr, :department),
      join: dr in assoc(udr, :departmentrole),
      preload: [department: d, departmentrole: dr]

    Repo.all(query)
  end

  @doc """
  Gets a single user_department_role.

  Raises `Ecto.NoResultsError` if the User department role does not exist.

  ## Examples

      iex> get_user_department_role!(123)
      %UserDepartmentRole{}

      iex> get_user_department_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_department_role!(id), do: Repo.get!(UserDepartmentRole, id)

  @doc """
  Gets a single user_department_role by its references
  """
  def get_user_department_role_by_references(user_id, department_id, departmentrole_id) do
    (from udr in UserDepartmentRole,
      where: udr.user_id == ^user_id,
      where: udr.department_id == ^department_id,
      where: udr.departmentrole_id == ^departmentrole_id)
    |> Repo.all()
    |> Enum.at(0)
  end

  @doc """
  Creates a user_department_role.

  ## Examples

      iex> create_user_department_role(%{field: value})
      {:ok, %UserDepartmentRole{}}

      iex> create_user_department_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_department_role(attrs \\ %{}) do
    %UserDepartmentRole{}
    |> UserDepartmentRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_department_role.

  ## Examples

      iex> update_user_department_role(user_department_role, %{field: new_value})
      {:ok, %UserDepartmentRole{}}

      iex> update_user_department_role(user_department_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_department_role(%UserDepartmentRole{} = user_department_role, attrs) do
    user_department_role
    |> UserDepartmentRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_department_role.

  ## Examples

      iex> delete_user_department_role(user_department_role)
      {:ok, %UserDepartmentRole{}}

      iex> delete_user_department_role(user_department_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_department_role(%UserDepartmentRole{} = user_department_role) do
    Repo.delete(user_department_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_department_role changes.

  ## Examples

      iex> change_user_department_role(user_department_role)
      %Ecto.Changeset{data: %UserDepartmentRole{}}

  """
  def change_user_department_role(%UserDepartmentRole{} = user_department_role, attrs \\ %{}) do
    UserDepartmentRole.changeset(user_department_role, attrs)
  end
end

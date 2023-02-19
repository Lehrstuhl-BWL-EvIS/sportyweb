defmodule Sportyweb.RBAC.Role do

  defstruct [:id, :name, :roles]

  @moduledoc """
  The RBAC.Role context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.RBAC.Role.ClubRole

  @doc """
  Returns the list of clubroles.

  ## Examples

      iex> list_clubroles()
      [%ClubRole{}, ...]

  """
  def list_clubroles do
    Repo.all(ClubRole)
  end

  @doc """
  Gets a single club_role.

  Raises `Ecto.NoResultsError` if the Club role does not exist.

  ## Examples

      iex> get_club_role!(123)
      %ClubRole{}

      iex> get_club_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_club_role!(id), do: Repo.get!(ClubRole, id)

  @doc """
  Creates a club_role.

  ## Examples

      iex> create_club_role(%{field: value})
      {:ok, %ClubRole{}}

      iex> create_club_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_club_role(attrs \\ %{}) do
    %ClubRole{}
    |> ClubRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a club_role.

  ## Examples

      iex> update_club_role(club_role, %{field: new_value})
      {:ok, %ClubRole{}}

      iex> update_club_role(club_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_club_role(%ClubRole{} = club_role, attrs) do
    club_role
    |> ClubRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a club_role.

  ## Examples

      iex> delete_club_role(club_role)
      {:ok, %ClubRole{}}

      iex> delete_club_role(club_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_club_role(%ClubRole{} = club_role) do
    Repo.delete(club_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking club_role changes.

  ## Examples

      iex> change_club_role(club_role)
      %Ecto.Changeset{data: %ClubRole{}}

  """
  def change_club_role(%ClubRole{} = club_role, attrs \\ %{}) do
    ClubRole.changeset(club_role, attrs)
  end

  @doc """
  Creates the role set linked to each department.
  """
  def create_department_roles do
    for club <- Sportyweb.Organization.list_clubs() do
      #IO.inspect(club)
      for department <- Sportyweb.Organization.list_departments(club.id) do
        #IO.inspect(department)
        Sportyweb.RBAC.Role.RolePermissionMatrix.get_role_names(:department) |> Enum.map(&(IO.puts("#{&1} - #{department.name}")))
      end
    end
  end


  alias Sportyweb.RBAC.Role.ApplicationRole

  @doc """
  Returns the list of applicationroles.

  ## Examples

      iex> list_applicationroles()
      [%ApplicationRole{}, ...]

  """
  def list_applicationroles do
    Repo.all(ApplicationRole)
  end

  @doc """
  Gets a single application_role.

  Raises `Ecto.NoResultsError` if the Application role does not exist.

  ## Examples

      iex> get_application_role!(123)
      %ApplicationRole{}

      iex> get_application_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_application_role!(id), do: Repo.get!(ApplicationRole, id)

  @doc """
  Creates a application_role.

  ## Examples

      iex> create_application_role(%{field: value})
      {:ok, %ApplicationRole{}}

      iex> create_application_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_application_role(attrs \\ %{}) do
    %ApplicationRole{}
    |> ApplicationRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a application_role.

  ## Examples

      iex> update_application_role(application_role, %{field: new_value})
      {:ok, %ApplicationRole{}}

      iex> update_application_role(application_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_application_role(%ApplicationRole{} = application_role, attrs) do
    application_role
    |> ApplicationRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a application_role.

  ## Examples

      iex> delete_application_role(application_role)
      {:ok, %ApplicationRole{}}

      iex> delete_application_role(application_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_application_role(%ApplicationRole{} = application_role) do
    Repo.delete(application_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking application_role changes.

  ## Examples

      iex> change_application_role(application_role)
      %Ecto.Changeset{data: %ApplicationRole{}}

  """
  def change_application_role(%ApplicationRole{} = application_role, attrs \\ %{}) do
    ApplicationRole.changeset(application_role, attrs)
  end
end

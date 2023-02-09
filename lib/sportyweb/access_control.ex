defmodule Sportyweb.AccessControl do
  @moduledoc """
  The AccessControl context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.AccessControl.ClubRole

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
  def get_club_role_by_name(name), do: Repo.get_by(ClubRole, name: name)

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

  alias Sportyweb.AccessControl.UserClubRole

  @doc """
  Returns the list of userclubroles.

  ## Examples

      iex> list_userclubroles()
      [%UserClubRole{}, ...]

  """
  def list_userclubroles do
    Repo.all(UserClubRole)
  end

  def list_userclubroles_data do
    query = from ucr in UserClubRole,
      join: u in assoc(ucr, :user),
      preload: [:user, :club, :clubrole],
      order_by: u.email

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
  Updates a user_club_role.

  ## Examples

  """
  def manage_user_club_role(%UserClubRole{} = user_club_role, attrs) do
    user_club_role
    |> UserClubRole.managechanges(attrs)
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

  alias Sportyweb.AccessControl.ApplicationRole

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

  alias Sportyweb.AccessControl.UserApplicationRole

  @doc """
  Returns the list of userapplicationroles.

  ## Examples

      iex> list_userapplicationroles()
      [%UserApplicationRole{}, ...]

  """
  def list_userapplicationroles do
    Repo.all(UserApplicationRole)
  end

  def list_userapplicationroles_data do
    query = from uar in UserApplicationRole,
      join: u in assoc(uar, :user),
      preload: [:user, :applicationrole],
      order_by: u.email

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
end

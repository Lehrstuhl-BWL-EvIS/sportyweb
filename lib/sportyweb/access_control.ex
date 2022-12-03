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

  alias Sportyweb.AccessControl.UserClubRoles

  @doc """
  Returns the list of userclubroles.

  ## Examples

      iex> list_userclubroles()
      [%UserClubRoles{}, ...]

  """
  def list_userclubroles do
    Repo.all(UserClubRoles)
  end

  @doc """
  Gets a single user_club_roles.

  Raises `Ecto.NoResultsError` if the User club roles does not exist.

  ## Examples

      iex> get_user_club_roles!(123)
      %UserClubRoles{}

      iex> get_user_club_roles!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_club_roles!(id), do: Repo.get!(UserClubRoles, id)

  @doc """
  Creates a user_club_roles.

  ## Examples

      iex> create_user_club_roles(%{field: value})
      {:ok, %UserClubRoles{}}

      iex> create_user_club_roles(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_club_roles(attrs \\ %{}) do
    %UserClubRoles{}
    |> UserClubRoles.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_club_roles.

  ## Examples

      iex> update_user_club_roles(user_club_roles, %{field: new_value})
      {:ok, %UserClubRoles{}}

      iex> update_user_club_roles(user_club_roles, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_club_roles(%UserClubRoles{} = user_club_roles, attrs) do
    user_club_roles
    |> UserClubRoles.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_club_roles.

  ## Examples

      iex> delete_user_club_roles(user_club_roles)
      {:ok, %UserClubRoles{}}

      iex> delete_user_club_roles(user_club_roles)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_club_roles(%UserClubRoles{} = user_club_roles) do
    Repo.delete(user_club_roles)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_club_roles changes.

  ## Examples

      iex> change_user_club_roles(user_club_roles)
      %Ecto.Changeset{data: %UserClubRoles{}}

  """
  def change_user_club_roles(%UserClubRoles{} = user_club_roles, attrs \\ %{}) do
    UserClubRoles.changeset(user_club_roles, attrs)
  end

  ### Policy Support ###

  alias Sportyweb.Accounts.User
  alias Sportyweb.Repo
  alias Sportyweb.Organization.Club
  alias Sportyweb.AccessControl.UserClubRoles, as: UCR

  def is_sportyweb_admin(%User{id: user_id}) do
    query = from ucr in UCR,
      where: ucr.user_id == ^user_id,
      join: cr in assoc(ucr, :clubrole),
      select: cr.name

      Enum.member?(Repo.all(query), "sportyweb_admin")
  end

  def get_role(%User{id: user_id}, club_id) do
    query = from ucr in UCR,
      where: ucr.user_id == ^user_id and ucr.club_id == ^club_id,
      join: cr in assoc(ucr, :clubrole),
      select: cr.name

    Repo.all(query)
  end
end

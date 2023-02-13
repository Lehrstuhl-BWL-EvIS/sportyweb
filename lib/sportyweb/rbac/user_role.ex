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

  @doc """
  Creates a user_club_role.

  ## Examples

      iex> create_user_club_role(%{field: value})
      {:ok, %UserClubRole{}}

      iex> create_user_club_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def get_user_club_role_preload(id) do
    query = from ucr in UserClubRole,
      where: ucr.id == ^id,
      join: u in assoc(ucr, :user),
      join: c in assoc(ucr, :club),
      join: cr in assoc(ucr, :clubrole),
      preload: [user: u, club: c, clubrole: cr]

    Repo.all(query)
  end

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
end

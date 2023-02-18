defmodule Sportyweb.Personal do
  @moduledoc """
  The Personal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Personal.Contact

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts(1)
      [%Contact{}, ...]

  """
  def list_contacts(club_id) do
    query = from(c in Contact, where: c.club_id == ^club_id, order_by: [c.organization_name, c.person_last_name, c.person_first_name_1, c.person_first_name_2])
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of contacts. Preloads associations.

  ## Examples

      iex> list_contacts(1, [:club])
      [%Contact{}, ...]

  """
  def list_contacts(club_id, preloads) do
    Repo.preload(list_contacts(club_id), preloads)
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  @doc """
  Gets a single contact. Preloads associations.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123, [:club])
      %Department{}

      iex> get_contact!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id, preloads) do
    Contact
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{data: %Contact{}}

  """
  def change_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset(contact, attrs)
  end
end

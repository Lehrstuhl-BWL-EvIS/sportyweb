defmodule Sportyweb.Personal do
  @moduledoc """
  The Personal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts(1)
      [%Contact{}, ...]

  """
  def list_contacts(club_id) do
    query = from(c in Contact, where: c.club_id == ^club_id, order_by: c.name)
    Repo.all(query)
  end
  def list_contacts(club_id, order_by, filters) do
    query = from(c in Contact, where: c.club_id == ^club_id)
    query = cond do
      order_by == nil -> order_by(query, asc: :name)
      true -> order_by(query, ^order_by)
    end
    query = cond do
      filters == nil || length(filters) == 0 -> query
      true -> where(query, ^filter_contacts_like(filters))
    end
    Repo.all(query)
  end
  def list_contacts(club_id, order_by, filters, preloads) do
    list_contacts(club_id, order_by, filters)
    |> Repo.preload(preloads)
  end

  defp filter_contacts_like(params) do
    Enum.reduce(params, dynamic(true), fn
      {:type, value}, dynamic -> dynamic([c], ^dynamic and ilike(c.type, ^value))
      {:name, value}, dynamic -> dynamic([c], ^dynamic and ilike(c.name, ^value))
      {:person_last_name, value}, dynamic -> dynamic([c], ^dynamic and ilike(c.person_last_name, ^value))
      {:person_first_name_1, value}, dynamic -> dynamic([c], ^dynamic and ilike(c.person_first_name_1, ^value))
      {:person_birthday, value}, dynamic -> dynamic([c], ^dynamic and ilike(c.person_birthday, ^value))
      {:person_gender, value}, dynamic -> dynamic([c], ^dynamic and ilike(c.person_gender, ^value))
    end)
  end

  def list_contacts_of_members(club_id, order_by, preloads) do
    order_by = cond do
      order_by == nil -> :name
      true -> order_by
    end

    query = from(c in Contact,
      as: :contact,
      where: exists(from m in Membership,
                    where: m.club_id == ^club_id and m.contact_id == parent_as(:contact).id,
                    select: 1
                    ),
      order_by: ^order_by)
    Repo.all(query)
    |> Repo.preload(preloads)
  end

  @doc """
  Returns a list of contacts that are possible options for the given contract.
  The list won't include contacts that have an active (non-archived) contract
  with the given contract_object.

  Example: If the contract_object is a certain club, all contacts which have
  active membership contracts with this club won't be part of the returned
  options list.

  ## Examples

      iex> list_contract_contact_options(1, 2)
      [%Contact{}, ...]

  """
  def list_contract_contact_options(contract, contract_object) do
    # Get all the ids of contacts that have an active contract with the contract_object.
    # These contacts won't appear in the select input as an option for the new contract.
    exclude_contact_ids =
      Enum.map(contract_object.contracts, fn contract ->
        if !Contract.is_archived?(contract, Date.utc_today()) do
          contract.contact_id
        end
      end)

    query =
      from(
        c in Contact,
        where: c.club_id == ^contract.club_id,
        where: c.id not in ^exclude_contact_ids,
        order_by: c.name
      )

    Repo.all(query)
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
      %Contact{}

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

  alias Sportyweb.Personal.ContactGroup

  @doc """
  Returns the list of contact_groups.

  ## Examples

      iex> list_contact_groups()
      [%ContactGroup{}, ...]

  """
  def list_contact_groups do
    Repo.all(ContactGroup)
  end

  @doc """
  Gets a single contact_group.

  Raises `Ecto.NoResultsError` if the Contact group does not exist.

  ## Examples

      iex> get_contact_group!(123)
      %ContactGroup{}

      iex> get_contact_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_group!(id), do: Repo.get!(ContactGroup, id)

  @doc """
  Creates a contact_group.

  ## Examples

      iex> create_contact_group(%{field: value})
      {:ok, %ContactGroup{}}

      iex> create_contact_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_group(attrs \\ %{}) do
    %ContactGroup{}
    |> ContactGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact_group.

  ## Examples

      iex> update_contact_group(contact_group, %{field: new_value})
      {:ok, %ContactGroup{}}

      iex> update_contact_group(contact_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact_group(%ContactGroup{} = contact_group, attrs) do
    contact_group
    |> ContactGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact_group.

  ## Examples

      iex> delete_contact_group(contact_group)
      {:ok, %ContactGroup{}}

      iex> delete_contact_group(contact_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact_group(%ContactGroup{} = contact_group) do
    Repo.delete(contact_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact_group changes.

  ## Examples

      iex> change_contact_group(contact_group)
      %Ecto.Changeset{data: %ContactGroup{}}

  """
  def change_contact_group(%ContactGroup{} = contact_group, attrs \\ %{}) do
    ContactGroup.changeset(contact_group, attrs)
  end

  @doc """
  Returns the list of memberships.

  ## Examples

      iex> list_memberships()
      [%Membership{}, ...]

  """
  def list_memberships(club_id) do
      query = from(m in Membership, where: m.club_id == ^club_id)
      Repo.all(query)
  end
  def list_memberships(club_id, order_by, filters) do
    query = from(m in Membership, where: m.club_id == ^club_id)
    query = cond do
      order_by == nil -> order_by(query, asc: :state)
      true -> order_by(query, ^order_by)
    end
    query = cond do
      filters == nil || length(filters) == 0 -> query
      true -> where(query, ^filters)
    end
    Repo.all(query)
  end
  def list_memberships(club_id, order_by, filters, preloads) do
    list_memberships(club_id, order_by, filters)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single membership.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(123)
      %Membership{}

      iex> get_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(id), do: Repo.get!(Membership, id)

  @doc """
  Gets a single membership. Preloads associations.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(123, [:club])
      %Contact{}

      iex> get_membership!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_membership!(id, preloads) do
    Membership
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  def list_memberships_of_contact_in_club(contact_id, club_id) do
    query = from(m in Membership, where: m.contact_id == ^contact_id and m.club_id == ^club_id
                                       and is_nil(m.department_id) and is_nil(m.group_id))
    Repo.all(query)
  end
  def list_memberships_of_contact_in_department(contact_id, department_id) do
    query = from(m in Membership, where: m.contact_id == ^contact_id and m.department_id == ^department_id
                                         and is_nil(m.group_id))
    Repo.all(query)
  end
  def list_memberships_of_contact_in_group(contact_id, group_id) do
    query = from(m in Membership, where: m.contact_id == ^contact_id and m.group_id == ^group_id)
    Repo.all(query)
  end


  @doc """
  Creates a membership.

  ## Examples

      iex> create_membership(%{field: value})
      {:ok, %Membership{}}

      iex> create_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(attrs \\ %{})
  def create_membership(%Ecto.Changeset{}  = changeset) do
    Repo.insert(changeset)
  end
  def create_membership(attrs) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end
  def update_membership(%Ecto.Changeset{} = changeset) do
    Repo.update(changeset)
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(membership)
      {:ok, %Membership{}}

      iex> delete_membership(membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end
end

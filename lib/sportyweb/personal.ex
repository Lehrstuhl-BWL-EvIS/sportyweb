defmodule Sportyweb.Personal do
  @moduledoc """
  The Personal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal.Contact

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

  defp filter_only_memberships_in(club_id, only_members_of, preloads) do
    query =
      from(c in Contact,
        join: m in Membership,
        on: m.contact_id == c.id,
        where:
          c.club_id == ^club_id and
            (m.club_id == ^only_members_of or m.department_id == ^only_members_of or
               m.group_id == ^only_members_of),
        distinct: c.id
      )

    preloads =
      if preloads == nil do
        nil
      else
        membership_query =
          from m in Membership,
            where:
              m.club_id == ^only_members_of or m.department_id == ^only_members_of or
                m.group_id == ^only_members_of

        Enum.map(preloads, fn p ->
          case p do
            :memberships -> {:memberships, membership_query}
            {:memberships, l} -> {:memberships, {membership_query, l}}
            _ -> p
          end
        end)
      end

    {query, preloads}
  end

  def list_contacts(club_id, order_by, filters, preloads \\ nil, only_members_of \\ nil) do
    {query, preloads} =
      if only_members_of == nil do
        query = from(c in Contact, where: c.club_id == ^club_id)
        {query, preloads}
      else
        filter_only_memberships_in(club_id, only_members_of, preloads)
      end

    query =
      if order_by == nil do
        order_by(query, asc: :name)
      else
        order_by(query, ^order_by)
      end

    query =
      if filters == nil || Enum.empty?(filters) do
        query
      else
        where(query, ^filter_contacts_like(filters))
      end

    all = Repo.all(query)

    if preloads == nil do
      all
    else
      all |> Repo.preload(preloads)
    end
  end

  defp filter_contacts_like(filters) do
    Enum.reduce(filters, dynamic(true), fn
      {:type, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.type, ^prepare_for_like(value)))

      {:name, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.name, ^prepare_for_like(value)))

      {:person_last_name, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.person_last_name, ^prepare_for_like(value)))

      {:person_first_name, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.person_first_name, ^prepare_for_like(value)))

      {:person_birthday, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.person_birthday, ^prepare_for_like(value)))

      {:person_gender, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.person_gender, ^prepare_for_like(value)))

      {:email, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.email, ^prepare_for_like(value)))

      {:phone, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.phone, ^prepare_for_like(value)))

      {:note, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.note, ^prepare_for_like(value)))#

      {:address_as_text, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.address_as_text, ^prepare_for_like(value)))
    end)
  end

  defp prepare_for_like(value) do
    "%#{value}%"
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
end

defmodule Sportyweb.Personal do
  @moduledoc """
  The Personal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroupContact
  alias Sportyweb.History

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
    membership_count_query =
      from(m in Membership,
        where:
          m.club_id == ^club_id and
            (m.club_id == ^only_members_of or
               m.department_id == ^only_members_of or
               m.group_id == ^only_members_of),
        group_by: m.contact_id,
        select: %{contact_id: m.contact_id, count: count()}
      )

    query =
      from(c in Contact,
        join: m in subquery(membership_count_query),
        on: m.contact_id == c.id,
        where: c.club_id == ^club_id and m.count > 0
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
        #
        dynamic([c], ^dynamic and ilike(c.note, ^prepare_for_like(value)))

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

      iex> create_contact(%{field: value}, %User{})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}, user) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
    |> History.add_creation("contact", user)
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value}, %User{})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs, user) do
    contact
    |> Contact.changeset(attrs)
    |> History.add_changes("contact", user)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact, %User{})
      {:ok, %Contact{}}

      iex> delete_contact(contact, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact, user) do
    contact
    |> delete_contact_from_contact_groups(user)
    |> Repo.delete()
    |> History.add_deletion("contact", user)
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
  Gets a single contact_group.

  Raises `Ecto.NoResultsError` if the Contact group does not exist.

  ## Examples

      iex> get_contact_group!(123)
      %ContactGroup{}

      iex> get_contact_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_group!(id, preloads \\ []) do
    ContactGroup
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a contact_group.

  ## Examples

      iex> create_contact_group(%{field: value}, %User{})
      {:ok, %ContactGroup{}}

      iex> create_contact_group(%{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_group(attrs \\ %{}, user) do
    %ContactGroup{}
    |> ContactGroup.changeset(attrs)
    |> Repo.insert()
    |> History.add_creation("contact_group", user)
  end

  @doc """
  Updates a contact_group.

  ## Examples

      iex> update_contact_group(contact_group, %{field: new_value}, %User{})
      {:ok, %ContactGroup{}}

      iex> update_contact_group(contact_group, %{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact_group(%ContactGroup{} = contact_group, attrs, user) do
    contact_group
    |> ContactGroup.changeset(attrs)
    |> History.add_changes("contact_group", user)
    |> Repo.update()
  end

  @doc """
  Deletes a contact_group.

  ## Examples

      iex> delete_contact_group(contact_group, %User{})
      {:ok, %ContactGroup{}}

      iex> delete_contact_group(contact_group, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact_group(%ContactGroup{} = contact_group, user) do
    contact_group
    |> Repo.delete()
    |> History.add_deletion("contact_group", user)
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

  def add_contact_group_contact(%ContactGroupContact{} = contact_group_contact, user) do
    res = Repo.insert(contact_group_contact)

    case res do
      {:ok, inserted_contact_group_contact} ->
        History.add_change(
          contact_group_contact.contact.club_id,
          "contact_group",
          inserted_contact_group_contact.contact_group_id,
          "contact_added",
          %{contact: inserted_contact_group_contact.contact_id},
          user
        )

      # nothing to do
      _ ->
        nil
    end

    res
  end

  def delete_contact_from_contact_groups(%Contact{} = contact, user) do
    _ =
      contact.contact_group_contacts
      |> Enum.map(fn cgc ->
        cgc = Map.put(cgc, :contact, contact)
        {:ok, _} = delete_contact_group_contact(cgc, user)
      end)

    contact
  end

  def delete_contact_group_contact(%ContactGroupContact{} = contact_group_contact, user) do
    res = Repo.delete(contact_group_contact)

    case res do
      {:ok, _} ->
        History.add_change(
          contact_group_contact.contact.club_id,
          "contact_group",
          contact_group_contact.contact_group_id,
          "contact_removed",
          %{contact: contact_group_contact.contact_id},
          user
        )

      # nothing to do
      _ ->
        nil
    end

    res
  end

  def delete_contacts_without_contracts(contacts_ids_to_check, job_name) do
    contacts_ids_to_check
    # delete all contacts that do no longer have an assigned contract
    |> Enum.dedup()
    |> Enum.map(fn contact_id ->
      Contact
      |> Repo.get!(contact_id)
      |> Repo.preload([:contracts, :memberships, :contact_group_contacts, :contact_groups])
    end)
    |> Enum.filter(fn contact ->
      Enum.empty?(contact.contracts) && Enum.empty?(contact.memberships)
    end)
    |> Enum.flat_map(fn contact ->
      {:ok, _} = delete_contact(contact, job_name)
      contact.contact_groups
    end)
    # delete all contact_groups that do no longer contain any contact
    |> Enum.dedup()
    |> Enum.map(fn contact_group ->
      ContactGroup
      |> Repo.get!(contact_group.id)
      |> Repo.preload(:contact_group_contacts)
    end)
    |> Enum.filter(fn contact_group -> Enum.empty?(contact_group.contact_group_contacts) end)
    |> Enum.map(fn contact_group ->
      {:ok, _} = delete_contact_group(contact_group, job_name)
      contact_group
    end)
  end
end

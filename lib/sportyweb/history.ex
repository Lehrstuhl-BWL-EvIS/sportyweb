defmodule Sportyweb.History do
  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.History.Change
  alias Sportyweb.Accounts.User

  def list_all_changes_of_club(club_id) do
    query =
      from(c in Change,
        where: c.club_id == ^club_id
      )

    query
    |> Repo.all()
  end

  def list_changes(entity_type, entity_id) do
    query =
      from(c in Change,
        where: c.entity_type == ^entity_type and c.entity_id == ^entity_id,
        order_by: [desc: c.changed_at]
      )

    query
    |> Repo.all()
  end

  def get_last_change(entity_type, entity_id) do
    query =
      from(c in Change,
        where: c.entity_type == ^entity_type and c.entity_id == ^entity_id,
        order_by: [desc: c.changed_at],
        limit: 1
      )

    query
    |> Repo.one()
  end

  def add_creation({:ok, entity} = repo_result, entity_type, user) do
    {:ok, _} = add_change(entity.club_id, entity_type, entity.id, "-creation-", "-", user)
    repo_result
  end

  def add_creation(repo_result, _, _), do: repo_result

  def add_deletion({:ok, entity} = repo_result, entity_type, user) do
    {:ok, _} = add_change(entity.club_id, entity_type, entity.id, "-deletion-", "-", user)
    repo_result
  end

  def add_deletion(repo_result, _, _), do: repo_result

  def add_changes(
        %Ecto.Changeset{changes: changes, data: data, valid?: true} = changeset,
        entity_type,
        user
      ) do
    for {attribute, new_value} <- changes do
      attribute_string = Atom.to_string(attribute)
      {:ok, _} = add_change(data.club_id, entity_type, data.id, attribute_string, new_value, user)
    end

    changeset
  end

  def add_changes(%Ecto.Changeset{} = changeset, _, _), do: changeset

  def add_change(club_id, entity_type, entity_id, attribute, new_value, user) do
    changed_by = write_user(user)
    new_value = write_new_value(new_value)

    {:ok, _} =
      res =
      %Change{}
      |> Change.changeset(%{
        club_id: club_id,
        entity_type: entity_type,
        entity_id: entity_id,
        attribute: attribute,
        new_value: new_value,
        changed_by: changed_by,
        changed_at: DateTime.utc_now()
      })
      |> Repo.insert()

    res
  end

  defp write_user(%User{} = user), do: user.email
  defp write_user(user) when is_binary(user), do: user

  defp write_new_value(nil), do: nil
  defp write_new_value(new_value) when is_binary(new_value), do: new_value
  defp write_new_value(%Date{} = new_value), do: Date.to_string(new_value)
  defp write_new_value(%Ecto.Changeset{changes: new_value}), do: Jason.encode!(new_value)
  defp write_new_value(new_value), do: Jason.encode!(new_value)
end

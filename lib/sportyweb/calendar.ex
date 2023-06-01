defmodule Sportyweb.Calendar do
  @moduledoc """
  The Calendar context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventFee
  alias Sportyweb.Finance.Fee

  @doc """
  Returns a clubs list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events(club_id) do
    query = from(e in Event, where: e.club_id == ^club_id)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of events. Preloads associations.

  ## Examples

      iex> list_events(1, [:club])
      [%Event{}, ...]

  """
  def list_events(club_id, preloads) do
    Repo.preload(list_events(club_id), preloads)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Gets a single event. Preloads associations.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123, [:club])
      %Event{}

      iex> get_event!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_event!(id, preloads) do
    Event
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @doc """
  Creates a event_fee (many_to_many).

  ## Examples

      iex> create_event_fee(event, fee)
      {:ok, %EventFee{}}

      iex> create_event_fee(event, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_event_fee(%Event{} = event, %Fee{} = fee) do
    Repo.insert(%EventFee{
      event_id: event.id,
      fee_id: fee.id
    })
  end
end

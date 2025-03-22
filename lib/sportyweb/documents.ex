defmodule Sportyweb.Documents do
  @moduledoc """
  The Calendar context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Documents.Document

  @doc """
  Returns a clubs list of documents.

  ## Examples

      iex> list_documents()
      [%Document{}, ...]

  """
  def list_documents(club_id) do
    query = from(e in Document, where: e.club_id == ^club_id)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of documents. Preloads associations.

  ## Examples

      iex> list_documents(1, [:club])
      [%Document{}, ...]

  """
  def list_documents(club_id, preloads) do
    Repo.preload(list_documents(club_id), preloads)
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id), do: Repo.get!(Document, id)

  @doc """
  Gets a single document. Preloads associations.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123, [:club])
      %Document{}

      iex> get_document!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_document!(id, preloads) do
    Document
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @document_types [
    {:contact_document, Sportyweb.Documents.ContactDocument},
    {:club_document, Sportyweb.Organization.ClubDocument}
  ]

  def get_document_extension(%Document{id: document_id}) do
    Enum.find_value(@document_types, fn {key, mod} ->
      case Repo.one(from d in mod, where: d.document_id == ^document_id) do
        nil -> nil
        record -> {key, record}
      end
    end)
  end

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{data: %Document{}}

  """
  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end
end

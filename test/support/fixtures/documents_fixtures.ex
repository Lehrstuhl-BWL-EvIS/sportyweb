defmodule Sportyweb.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Documents` context.
  """

  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    club = club_fixture()
    user = user_fixture()

    {:ok, document} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        uploaded_by_id: user.id,
        title: "some title",
        description: "some description",
        filename: "somefile.txt",
        content_type: "text/plain",
        byte_size: 123,
        storage_path: "some/path",
        checksum: String.duplicate("a", 64)
      })
      |> Sportyweb.Documents.create_document()

    document
  end

  @doc """
  Generate a club document along with its base document.
  Returns a map containing :document and :club_document keys.
  """
  def club_document_fixture(attrs \\ %{}) do
    %{document: document} = %{document: document_fixture()}

    params =
      attrs
      |> Enum.into(%{
        club_id: document.club_id,
        document_id: document.id,
        type: "custom"
      })

    {:ok, club_document} =
      %Sportyweb.Documents.ClubDocument{}
      |> Sportyweb.Documents.ClubDocument.changeset(params)
      |> Sportyweb.Repo.insert()

    %{document: document, club_document: club_document}
  end
end

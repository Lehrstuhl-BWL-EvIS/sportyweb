defmodule Sportyweb.DocumentsTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Documents

  describe "documents" do
    alias Sportyweb.Documents.Document

    import Sportyweb.DocumentsFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.AccountsFixtures

    @invalid_attrs %{
      title: nil,
      description: nil,
      filename: nil,
      content_type: nil,
      byte_size: nil,
      storage_path: nil,
      checksum: nil,
      club_id: nil,
      uploaded_by_id: nil
    }

    test "list_documents/1 returns all documents of a given club" do
      document = document_fixture()
      assert List.first(Documents.list_documents(document.club_id)).id == document.id
    end

    test "list_documents/2 returns all documents of a given club with preloaded associations" do
      document = document_fixture()
      assert Documents.list_documents(document.club_id, [:uploaded_by]) == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Documents.get_document!(document.id).id == document.id
    end

    test "get_document!/2 returns the document with given id and contains preloaded associations" do
      document = document_fixture()
      assert Documents.get_document!(document.id, [:uploaded_by]) == document
    end

    test "create_document/1 with valid data creates a document" do
      club = club_fixture()
      user = user_fixture()

      valid_attrs = %{
        club_id: club.id,
        uploaded_by_id: user.id,
        title: "some title",
        description: "some description",
        filename: "test.txt",
        content_type: "text/plain",
        byte_size: 42,
        storage_path: "path/one",
        checksum: String.duplicate("b", 64)
      }

      assert {:ok, %Document{} = document} = Documents.create_document(valid_attrs)
      assert document.title == "some title"
      assert document.description == "some description"
      assert document.filename == "test.txt"
      assert document.content_type == "text/plain"
      assert document.byte_size == 42
      assert document.storage_path == "path/one"
      assert document.checksum == String.duplicate("b", 64)
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()

      update_attrs = %{
        title: "updated title",
        description: "updated description",
        filename: "updated.txt",
        content_type: "application/pdf",
        byte_size: 100,
        storage_path: "path/two",
        checksum: String.duplicate("c", 64)
      }

      assert {:ok, %Document{} = document} = Documents.update_document(document, update_attrs)
      assert document.title == "updated title"
      assert document.description == "updated description"
      assert document.filename == "updated.txt"
      assert document.content_type == "application/pdf"
      assert document.byte_size == 100
      assert document.storage_path == "path/two"
      assert document.checksum == String.duplicate("c", 64)
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_document(document, @invalid_attrs)
      assert document == Documents.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Documents.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end
end

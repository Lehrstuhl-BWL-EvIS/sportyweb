defmodule SportywebWeb.DocumentLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.DocumentsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  defp create_document(_) do
    %{document: document} = club_document_fixture()
    %{document: document}
  end

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  describe "Index" do
    setup [:create_document]

    test "lists all documents - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/documents")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/documents")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all documents", %{conn: conn, user: user, document: document} do
      {:error, _} = live(conn, ~p"/clubs/#{document.club_id}/documents")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{document.club_id}/documents")

      assert html =~ "Dokumente"
      assert html =~ document.title
    end
  end

  describe "Show" do
    setup [:create_document]

    test "displays document", %{conn: conn, user: user, document: document} do
      {:error, _} = live(conn, ~p"/documents/#{document}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/documents/#{document}")

      assert html =~ "Dokument bearbeiten"
      assert html =~ document.title
    end

    test "deletes document", %{conn: conn, user: user, document: document} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/documents/#{document}")

      edit_live |> element("button", "Löschen") |> render_click()

      {:ok, _, html} =
        edit_live
        |> element("#confirm-delete-modal button", "Ja, löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{document.club_id}")

      assert html =~ "Dokument wurde gelöscht"
      assert html =~ "Verein:"
    end
  end
end

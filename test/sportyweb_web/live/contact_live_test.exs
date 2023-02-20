defmodule SportywebWeb.ContactLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.PersonalFixtures

  @create_attrs %{organization_name: "some organization_name", organization_type: "club", person_birthday: ~D[2022-11-05], person_first_name_1: "some person_first_name_1", person_first_name_2: "some person_first_name_2", person_gender: "male", person_last_name: "some person_last_name", type: "person"}
  @update_attrs %{organization_name: "some updated organization_name", organization_type: "corporation", person_birthday: ~D[2022-11-06], person_first_name_1: "some updated person_first_name_1", person_first_name_2: "some updated person_first_name_2", person_gender: "female", person_last_name: "some updated person_last_name", type: "organization"}
  @invalid_attrs %{organization_name: nil, organization_type: nil, person_birthday: nil, person_first_name_1: nil, person_first_name_2: nil, person_gender: nil, person_last_name: nil, type: nil}

  setup do
    %{user: user_fixture()}
  end

  defp create_contact(_) do
    contact = contact_fixture()
    %{contact: contact}
  end

  describe "Index" do
    setup [:create_contact]

    test "lists all contacts - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/contacts")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/contacts")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all contacts", %{conn: conn, user: user, contact: contact} do
      {:error, _} = live(conn, ~p"/clubs/#{contact.club_id}/contacts")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{contact.club_id}/contacts")

      assert html =~ "Kontakte"
      assert html =~ contact.name
    end
  end

  describe "New/Edit" do
    setup [:create_contact]

    test "saves new contact", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/contacts/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/contacts/new")

      assert html =~ "Kontakt erstellen"

      assert new_live
              |> form("#contact-form", contact: @invalid_attrs)
              |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#contact-form", contact: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/contacts")

      assert html =~ "Kontakt erfolgreich erstellt"
      assert html =~ "some person_last_name"
    end

    test "updates contact", %{conn: conn, user: user, contact: contact} do
      {:error, _} = live(conn, ~p"/contacts/#{contact}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/contacts/#{contact}/edit")

      assert html =~ "Kontakt bearbeiten"

      assert edit_live
             |> form("#contact-form", contact: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#contact-form", contact: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/contacts/#{contact}")

      assert html =~ "Kontakt erfolgreich aktualisiert"
      assert html =~ contact.name
    end
  end

  describe "Show" do
    setup [:create_contact]

    test "displays contact", %{conn: conn, user: user, contact: contact} do
      {:error, _} = live(conn, ~p"/contacts/#{contact}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/contacts/#{contact}")

      assert html =~ "Kontakt:"
      assert html =~ contact.name
    end
  end
end

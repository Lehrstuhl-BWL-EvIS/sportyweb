defmodule SportywebWeb.ApplicationRoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccessControlFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_application_role(_) do
    application_role = application_role_fixture()
    %{application_role: application_role}
  end

  describe "Index" do
    setup [:create_application_role]

    test "lists all applicationroles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/applicationroles")

      assert html =~ "Listing Applicationroles"
    end

    test "saves new application_role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/applicationroles")

      assert index_live |> element("a", "New Application role") |> render_click() =~
               "New Application role"

      assert_patch(index_live, ~p"/applicationroles/new")

      assert index_live
             |> form("#application_role-form", application_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#application_role-form", application_role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/applicationroles")

      assert html =~ "Application role created successfully"
    end

    test "updates application_role in listing", %{conn: conn, application_role: application_role} do
      {:ok, index_live, _html} = live(conn, ~p"/applicationroles")

      assert index_live |> element("#applicationroles-#{application_role.id} a", "Edit") |> render_click() =~
               "Edit Application role"

      assert_patch(index_live, ~p"/applicationroles/#{application_role}/edit")

      assert index_live
             |> form("#application_role-form", application_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#application_role-form", application_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/applicationroles")

      assert html =~ "Application role updated successfully"
    end

    test "deletes application_role in listing", %{conn: conn, application_role: application_role} do
      {:ok, index_live, _html} = live(conn, ~p"/applicationroles")

      assert index_live |> element("#applicationroles-#{application_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#application_role-#{application_role.id}")
    end
  end

  describe "Show" do
    setup [:create_application_role]

    test "displays application_role", %{conn: conn, application_role: application_role} do
      {:ok, _show_live, html} = live(conn, ~p"/applicationroles/#{application_role}")

      assert html =~ "Show Application role"
    end

    test "updates application_role within modal", %{conn: conn, application_role: application_role} do
      {:ok, show_live, _html} = live(conn, ~p"/applicationroles/#{application_role}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Application role"

      assert_patch(show_live, ~p"/applicationroles/#{application_role}/show/edit")

      assert show_live
             |> form("#application_role-form", application_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#application_role-form", application_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/applicationroles/#{application_role}")

      assert html =~ "Application role updated successfully"
    end
  end
end

defmodule SportywebWeb.DepartmentLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures

  @create_attrs %{name: "some name", reference_number: "some reference_number", description: "some description", created_at: ~D[2022-11-05]}
  @update_attrs %{name: "some updated name", reference_number: "some updated reference_number", description: "some updated description", created_at: ~D[2022-11-06]}
  @invalid_attrs %{name: nil, reference_number: nil, description: nil, created_at: nil}

  setup do
    %{user: user_fixture()}
  end

  defp create_department(_) do
    department = department_fixture()
    %{department: department}
  end

  describe "Index" do
    setup [:create_department]

    test "lists all departments - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/departments")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/departments")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all departments", %{conn: conn, user: user, department: department} do
      {:error, _} = live(conn, ~p"/clubs/#{department.club_id}/departments")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{department.club_id}/departments")

      assert html =~ "Abteilungen"
      assert html =~ department.name
    end
  end

  describe "New/Edit" do
    setup [:create_department]

    test "saves new department", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/departments/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/departments/new")

      assert html =~ "Abteilung erstellen"

      assert new_live
              |> form("#department-form", department: @invalid_attrs)
              |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#department-form", department: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/departments")

      assert html =~ "Abteilung erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new department", %{conn: conn, user: user} do
      club = club_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/departments/new")

      {:ok, _, _html} =
        new_live
        |> element("#department-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club}/departments")
    end

    test "updates department", %{conn: conn, user: user, department: department} do
      {:error, _} = live(conn, ~p"/departments/#{department}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/departments/#{department}/edit")

      assert html =~ "Abteilung bearbeiten"

      assert edit_live
             |> form("#department-form", department: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#department-form", department: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departments/#{department}")

      assert html =~ "Abteilung erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates department", %{conn: conn, user: user, department: department} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/departments/#{department}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#department-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/departments/#{department}")
    end

    test "deletes department", %{conn: conn, user: user, department: department} do
      {:error, _} = live(conn, ~p"/departments/#{department}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/departments/#{department}/edit")
      assert html =~ "some name"

      {:ok, _, html} =
        edit_live
        |> element("#department-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{department.club_id}/departments")

      assert html =~ "Abteilung erfolgreich gelöscht"
      assert html =~ "Abteilungen"
      refute html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_department]

    test "displays department", %{conn: conn, user: user, department: department} do
      {:error, _} = live(conn, ~p"/departments/#{department}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/departments/#{department}")

      assert html =~ "Abteilung:"
      assert html =~ department.name
      assert html =~ "Gruppen"
    end
  end
end

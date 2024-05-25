defmodule SportywebWeb.LocationLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.AssetFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.PolymorphicFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{
    description: "some description",
    name: "some name",
    reference_number: "some reference_number",
    postal_addresses: %{
      "0" => postal_address_attrs()
    }
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    reference_number: "some updated reference_number"
  }
  @invalid_attrs %{
    description: nil,
    name: nil,
    reference_number: nil
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_location(_) do
    location = location_fixture()
    %{location: location}
  end

  describe "Index" do
    setup [:create_location]

    test "lists all locations - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/locations")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/locations")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all locations", %{conn: conn, user: user, location: location} do
      {:error, _} = live(conn, ~p"/clubs/#{location.club_id}/locations")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{location.club_id}/locations")

      assert html =~ "Standorte"
      assert html =~ location.name
    end
  end

  describe "New/Edit" do
    setup [:create_location]

    test "saves new location", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/locations/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/locations/new")

      assert html =~ "Standort erstellen"

      assert new_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#location-form", location: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/locations")

      assert html =~ "Standort erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new location", %{conn: conn, user: user} do
      club = club_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/locations/new")

      {:ok, _, _html} =
        new_live
        |> element("#location-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club}/locations")
    end

    test "updates location", %{conn: conn, user: user, location: location} do
      {:error, _} = live(conn, ~p"/locations/#{location}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/locations/#{location}/edit")

      assert html =~ "Standort bearbeiten"

      assert edit_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#location-form", location: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/locations/#{location}")

      assert html =~ "Standort erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates location", %{conn: conn, user: user, location: location} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/locations/#{location}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#location-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/locations/#{location}")
    end

    test "deletes location", %{conn: conn, user: user, location: location} do
      {:error, _} = live(conn, ~p"/locations/#{location}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/locations/#{location}/edit")
      assert html =~ "some name"

      {:ok, _, html} =
        edit_live
        |> element("#location-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{location.club_id}/locations")

      assert html =~ "Standort erfolgreich gelöscht"
      assert html =~ "Standorte"
      refute html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_location]

    test "displays location", %{conn: conn, user: user, location: location} do
      {:error, _} = live(conn, ~p"/locations/#{location}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/locations/#{location}")

      assert html =~ "Standort:"
      assert html =~ location.name
    end
  end

  describe "FeeNew" do
    setup [:create_location]

    test "saves new location fee", %{conn: conn, user: user, location: location} do
      {:error, _} = live(conn, ~p"/locations/#{location}/fees/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/locations/#{location}/fees/new")

      assert html =~ "Spezifische Gebühr erstellen (Standort)"

      assert new_live
             |> form("#fee-form", fee: %{})
             |> render_change() =~ "can&#39;t be blank"

      create_attrs = %{
        amount: "30 €",
        amount_one_time: "10 €",
        name: "some name",
        internal_events: %{
          "0" => %{
            commission_date: ~D[2022-11-03]
          }
        }
      }

      {:ok, _, html} =
        new_live
        |> form("#fee-form", fee: create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/locations/#{location}")

      assert html =~ "Gebühr erfolgreich erstellt"
      assert html =~ location.name
    end
  end
end

defmodule SportywebWeb.EquipmentLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.AssetFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{
    commission_date: ~D[2022-11-10],
    decommission_date: ~D[2022-11-15],
    description: "some description",
    name: "some name",
    purchase_date: ~D[2022-11-05],
    reference_number: "some reference_number",
    serial_number: "some serial_number"
  }
  @update_attrs %{
    commission_date: ~D[2022-11-11],
    decommission_date: ~D[2022-11-16],
    description: "some updated description",
    name: "some updated name",
    purchase_date: ~D[2022-11-06],
    reference_number: "some updated reference_number",
    serial_number: "some updated serial_number"
  }
  @invalid_attrs %{
    commission_date: nil,
    decommission_date: nil,
    description: nil,
    name: nil,
    purchase_date: nil,
    reference_number: nil,
    serial_number: nil
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_equipment(_) do
    equipment = equipment_fixture()
    %{equipment: equipment}
  end

  describe "Index" do
    setup [:create_equipment]

    test "lists all equipment - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/equipment")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/equipment")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all equipment - redirect", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/locations/#{equipment.location_id}/equipment")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/locations/#{equipment.location_id}/equipment")
        |> follow_redirect(conn, ~p"/locations/#{equipment.location_id}")

      assert conn.resp_body =~ "Standort:"
    end
  end

  describe "New/Edit" do
    setup [:create_equipment]

    test "saves new equipment", %{conn: conn, user: user} do
      location = location_fixture()

      {:error, _} = live(conn, ~p"/locations/#{location}/equipment/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/locations/#{location}/equipment/new")

      assert html =~ "Equipment erstellen"

      assert new_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#equipment-form", equipment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/locations/#{location}")

      assert html =~ "Equipment erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new equipment", %{conn: conn, user: user} do
      location = location_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/locations/#{location}/equipment/new")

      {:ok, _, _html} =
        new_live
        |> element("#equipment-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/locations/#{location}")
    end

    test "updates equipment", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/equipment/#{equipment}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/equipment/#{equipment}/edit")

      assert html =~ "Equipment bearbeiten"

      assert edit_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#equipment-form", equipment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/equipment/#{equipment}")

      assert html =~ "Equipment erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates equipment", %{conn: conn, user: user, equipment: equipment} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/equipment/#{equipment}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#equipment-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/equipment/#{equipment}")
    end

    test "deletes equipment", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/equipment/#{equipment}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/equipment/#{equipment}/edit")
      assert html =~ "some serial_number"

      {:ok, _, html} =
        edit_live
        |> element("#equipment-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/locations/#{equipment.location_id}")

      assert html =~ "Equipment erfolgreich gelöscht"
      assert html =~ "Equipment"
      refute html =~ "some serial_number"
    end
  end

  describe "Show" do
    setup [:create_equipment]

    test "displays equipment", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/equipment/#{equipment}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/equipment/#{equipment}")

      assert html =~ "Equipment:"
      assert html =~ equipment.name
    end
  end

  describe "FeeNew" do
    setup [:create_equipment]

    test "saves new equipment fee", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/equipment/#{equipment}/fees/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/equipment/#{equipment}/fees/new")

      assert html =~ "Spezifische Gebühr erstellen (Equipment)"

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
        |> follow_redirect(conn, ~p"/equipment/#{equipment}")

      assert html =~ "Gebühr erfolgreich erstellt"
      assert html =~ equipment.name
    end
  end
end

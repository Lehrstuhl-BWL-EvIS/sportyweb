defmodule SportywebWeb.EquipmentLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AssetFixtures

  @create_attrs %{commission_at: "2023-2-14", decommission_at: "2023-2-14", description: "some description", name: "some name", purchased_at: "2023-2-14", reference_number: "some reference_number", serial_number: "some serial_number"}
  @update_attrs %{commission_at: "2023-2-15", decommission_at: "2023-2-15", description: "some updated description", name: "some updated name", purchased_at: "2023-2-15", reference_number: "some updated reference_number", serial_number: "some updated serial_number"}
  @invalid_attrs %{commission_at: nil, decommission_at: nil, description: nil, name: nil, purchased_at: nil, reference_number: nil, serial_number: nil}

  defp create_equipment(_) do
    equipment = equipment_fixture()
    %{equipment: equipment}
  end

  describe "Index" do
    setup [:create_equipment]

    test "lists all equipment", %{conn: conn, equipment: equipment} do
      {:ok, _index_live, html} = live(conn, ~p"/equipment")

      assert html =~ "Listing Equipment"
      assert html =~ equipment.description
    end

    test "saves new equipment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/equipment")

      assert index_live |> element("a", "New Equipment") |> render_click() =~
               "New Equipment"

      assert_patch(index_live, ~p"/equipment/new")

      assert index_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#equipment-form", equipment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/equipment")

      assert html =~ "Equipment created successfully"
      assert html =~ "some description"
    end

    test "updates equipment in listing", %{conn: conn, equipment: equipment} do
      {:ok, index_live, _html} = live(conn, ~p"/equipment")

      assert index_live |> element("#equipment-#{equipment.id} a", "Edit") |> render_click() =~
               "Edit Equipment"

      assert_patch(index_live, ~p"/equipment/#{equipment}/edit")

      assert index_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#equipment-form", equipment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/equipment")

      assert html =~ "Equipment updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes equipment in listing", %{conn: conn, equipment: equipment} do
      {:ok, index_live, _html} = live(conn, ~p"/equipment")

      assert index_live |> element("#equipment-#{equipment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#equipment-#{equipment.id}")
    end
  end

  describe "Show" do
    setup [:create_equipment]

    test "displays equipment", %{conn: conn, equipment: equipment} do
      {:ok, _show_live, html} = live(conn, ~p"/equipment/#{equipment}")

      assert html =~ "Show Equipment"
      assert html =~ equipment.description
    end

    test "updates equipment within modal", %{conn: conn, equipment: equipment} do
      {:ok, show_live, _html} = live(conn, ~p"/equipment/#{equipment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Equipment"

      assert_patch(show_live, ~p"/equipment/#{equipment}/show/edit")

      assert show_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#equipment-form", equipment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/equipment/#{equipment}")

      assert html =~ "Equipment updated successfully"
      assert html =~ "some updated description"
    end
  end
end

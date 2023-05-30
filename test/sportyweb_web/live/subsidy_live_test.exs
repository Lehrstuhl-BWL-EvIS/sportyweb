defmodule SportywebWeb.SubsidyLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.LegalFixtures

  @create_attrs %{archive_date: "2023-05-29", commission_date: "2023-05-29", description: "some description", name: "some name", reference_number: "some reference_number", value: 42}
  @update_attrs %{archive_date: "2023-05-30", commission_date: "2023-05-30", description: "some updated description", name: "some updated name", reference_number: "some updated reference_number", value: 43}
  @invalid_attrs %{archive_date: nil, commission_date: nil, description: nil, name: nil, reference_number: nil, value: nil}

  defp create_subsidy(_) do
    subsidy = subsidy_fixture()
    %{subsidy: subsidy}
  end

  describe "Index" do
    setup [:create_subsidy]

    test "lists all subsidies", %{conn: conn, subsidy: subsidy} do
      {:ok, _index_live, html} = live(conn, ~p"/subsidies")

      assert html =~ "Listing Subsidies"
      assert html =~ subsidy.description
    end

    test "saves new subsidy", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/subsidies")

      assert index_live |> element("a", "New Subsidy") |> render_click() =~
               "New Subsidy"

      assert_patch(index_live, ~p"/subsidies/new")

      assert index_live
             |> form("#subsidy-form", subsidy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#subsidy-form", subsidy: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/subsidies")

      html = render(index_live)
      assert html =~ "Subsidy created successfully"
      assert html =~ "some description"
    end

    test "updates subsidy in listing", %{conn: conn, subsidy: subsidy} do
      {:ok, index_live, _html} = live(conn, ~p"/subsidies")

      assert index_live |> element("#subsidies-#{subsidy.id} a", "Edit") |> render_click() =~
               "Edit Subsidy"

      assert_patch(index_live, ~p"/subsidies/#{subsidy}/edit")

      assert index_live
             |> form("#subsidy-form", subsidy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#subsidy-form", subsidy: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/subsidies")

      html = render(index_live)
      assert html =~ "Subsidy updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes subsidy in listing", %{conn: conn, subsidy: subsidy} do
      {:ok, index_live, _html} = live(conn, ~p"/subsidies")

      assert index_live |> element("#subsidies-#{subsidy.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#subsidies-#{subsidy.id}")
    end
  end

  describe "Show" do
    setup [:create_subsidy]

    test "displays subsidy", %{conn: conn, subsidy: subsidy} do
      {:ok, _show_live, html} = live(conn, ~p"/subsidies/#{subsidy}")

      assert html =~ "Show Subsidy"
      assert html =~ subsidy.description
    end

    test "updates subsidy within modal", %{conn: conn, subsidy: subsidy} do
      {:ok, show_live, _html} = live(conn, ~p"/subsidies/#{subsidy}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Subsidy"

      assert_patch(show_live, ~p"/subsidies/#{subsidy}/show/edit")

      assert show_live
             |> form("#subsidy-form", subsidy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#subsidy-form", subsidy: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/subsidies/#{subsidy}")

      html = render(show_live)
      assert html =~ "Subsidy updated successfully"
      assert html =~ "some updated description"
    end
  end
end

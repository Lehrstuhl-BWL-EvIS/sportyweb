defmodule SportywebWeb.FeeLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.LegalFixtures

  @create_attrs %{admission_fee_in_eur_cent: 42, base_fee_in_eur_cent: 42, commission_at: "2023-02-24", decommission_at: "2023-02-24", description: "some description", has_admission_fee: true, is_group_only: true, is_recurring: true, maximum_age_in_years: 42, minimum_age_in_years: 42, name: "some name", reference_number: "some reference_number", type: "some type"}
  @update_attrs %{admission_fee_in_eur_cent: 43, base_fee_in_eur_cent: 43, commission_at: "2023-02-25", decommission_at: "2023-02-25", description: "some updated description", has_admission_fee: false, is_group_only: false, is_recurring: false, maximum_age_in_years: 43, minimum_age_in_years: 43, name: "some updated name", reference_number: "some updated reference_number", type: "some updated type"}
  @invalid_attrs %{admission_fee_in_eur_cent: nil, base_fee_in_eur_cent: nil, commission_at: nil, decommission_at: nil, description: nil, has_admission_fee: false, is_group_only: false, is_recurring: false, maximum_age_in_years: nil, minimum_age_in_years: nil, name: nil, reference_number: nil, type: nil}

  defp create_fee(_) do
    fee = fee_fixture()
    %{fee: fee}
  end

  describe "Index" do
    setup [:create_fee]

    test "lists all fees", %{conn: conn, fee: fee} do
      {:ok, _index_live, html} = live(conn, ~p"/fees")

      assert html =~ "Listing Fees"
      assert html =~ fee.description
    end

    test "saves new fee", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/fees")

      assert index_live |> element("a", "New Fee") |> render_click() =~
               "New Fee"

      assert_patch(index_live, ~p"/fees/new")

      assert index_live
             |> form("#fee-form", fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fee-form", fee: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fees")

      html = render(index_live)
      assert html =~ "Fee created successfully"
      assert html =~ "some description"
    end

    test "updates fee in listing", %{conn: conn, fee: fee} do
      {:ok, index_live, _html} = live(conn, ~p"/fees")

      assert index_live |> element("#fees-#{fee.id} a", "Edit") |> render_click() =~
               "Edit Fee"

      assert_patch(index_live, ~p"/fees/#{fee}/edit")

      assert index_live
             |> form("#fee-form", fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fee-form", fee: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fees")

      html = render(index_live)
      assert html =~ "Fee updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes fee in listing", %{conn: conn, fee: fee} do
      {:ok, index_live, _html} = live(conn, ~p"/fees")

      assert index_live |> element("#fees-#{fee.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#fees-#{fee.id}")
    end
  end

  describe "Show" do
    setup [:create_fee]

    test "displays fee", %{conn: conn, fee: fee} do
      {:ok, _show_live, html} = live(conn, ~p"/fees/#{fee}")

      assert html =~ "Show Fee"
      assert html =~ fee.description
    end

    test "updates fee within modal", %{conn: conn, fee: fee} do
      {:ok, show_live, _html} = live(conn, ~p"/fees/#{fee}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Fee"

      assert_patch(show_live, ~p"/fees/#{fee}/show/edit")

      assert show_live
             |> form("#fee-form", fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#fee-form", fee: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/fees/#{fee}")

      html = render(show_live)
      assert html =~ "Fee updated successfully"
      assert html =~ "some updated description"
    end
  end
end

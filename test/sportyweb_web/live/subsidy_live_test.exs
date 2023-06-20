# #######################################################
# NOTE:
#   The following tests can only work after a new policy
#   has been introduced for the given entity.
#   After this has been done, uncomment the code below
#   and remove this note.
# #######################################################

# defmodule SportywebWeb.SubsidyLiveTest do
#   use SportywebWeb.ConnCase

#   import Phoenix.LiveViewTest
#   import Sportyweb.AccountsFixtures
#   import Sportyweb.FinanceFixtures
#   import Sportyweb.OrganizationFixtures

#   @create_attrs %{
#     name: "some name",
#     reference_number: "some reference_number",
#     description: "some description",
#     amount: "42 €"
#   }
#   @update_attrs %{
#     name: "some updated name",
#     reference_number: "some updated reference_number",
#     description: "some updated description",
#     value: "43 €"
#   }
#   @invalid_attrs %{
#     name: nil,
#     reference_number: nil,
#     description: nil,
#     value: nil
#   }

#   setup do
#     %{user: user_fixture()}
#   end

#   defp create_subsidy(_) do
#     subsidy = subsidy_fixture()
#     %{subsidy: subsidy}
#   end

#   describe "Index" do
#     setup [:create_subsidy]

#     test "lists all subsidies - default redirect", %{conn: conn, user: user} do
#       {:error, _} = live(conn, ~p"/subsidies")

#       conn = conn |> log_in_user(user)

#       {:ok, conn} =
#         conn
#         |> live(~p"/subsidies")
#         |> follow_redirect(conn, ~p"/clubs")

#       assert conn.resp_body =~ "Vereinsübersicht"
#     end

#     test "lists all subsidies", %{conn: conn, user: user, subsidy: subsidy} do
#       {:error, _} = live(conn, ~p"/clubs/#{subsidy.club_id}/subsidies")

#       conn = conn |> log_in_user(user)
#       {:ok, _index_live, html} = live(conn, ~p"/clubs/#{subsidy.club_id}/subsidies")

#       assert html =~ "Zuschüsse"
#       assert html =~ subsidy.name
#     end
#   end

#   describe "New/Edit" do
#     setup [:create_subsidy]

#     test "saves new subsidy", %{conn: conn, user: user} do
#       club = club_fixture()

#       {:error, _} = live(conn, ~p"/clubs/#{club}/subsidies/new")

#       conn = conn |> log_in_user(user)
#       {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/subsidies/new")

#       assert html =~ "Zuschuss erstellen"

#       assert new_live
#              |> form("#subsidy-form", subsidy: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       {:ok, _, html} =
#         new_live
#         |> form("#subsidy-form", subsidy: @create_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, ~p"/clubs/#{club}/subsidies")

#       assert html =~ "Zuschuss erfolgreich erstellt"
#       assert html =~ "some name"
#     end

#     test "cancels save new subsidy", %{conn: conn, user: user} do
#       club = club_fixture()

#       conn = conn |> log_in_user(user)
#       {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/subsidies/new")

#       {:ok, _, _html} =
#         new_live
#         |> element("#subsidy-form a", "Abbrechen")
#         |> render_click()
#         |> follow_redirect(conn, ~p"/clubs/#{club}/subsidies")
#     end

#     test "updates subsidy", %{conn: conn, user: user, subsidy: subsidy} do
#       {:error, _} = live(conn, ~p"/subsidies/#{subsidy}/edit")

#       conn = conn |> log_in_user(user)
#       {:ok, edit_live, html} = live(conn, ~p"/subsidies/#{subsidy}/edit")

#       assert html =~ "Zuschuss bearbeiten"

#       assert edit_live
#              |> form("#subsidy-form", subsidy: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       {:ok, _, html} =
#         edit_live
#         |> form("#subsidy-form", subsidy: @update_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, ~p"/subsidies/#{subsidy}")

#       assert html =~ "Zuschuss erfolgreich aktualisiert"
#       assert html =~ "some updated name"
#     end

#     test "cancels updates subsidy", %{conn: conn, user: user, subsidy: subsidy} do
#       conn = conn |> log_in_user(user)
#       {:ok, edit_live, _html} = live(conn, ~p"/subsidies/#{subsidy}/edit")

#       {:ok, _, _html} =
#         edit_live
#         |> element("#subsidy-form a", "Abbrechen")
#         |> render_click()
#         |> follow_redirect(conn, ~p"/subsidies/#{subsidy}")
#     end

#     test "deletes subsidy", %{conn: conn, user: user, subsidy: subsidy} do
#       {:error, _} = live(conn, ~p"/subsidies/#{subsidy}/edit")

#       conn = conn |> log_in_user(user)
#       {:ok, edit_live, html} = live(conn, ~p"/subsidies/#{subsidy}/edit")
#       assert html =~ "some name"

#       {:ok, _, html} =
#         edit_live
#         |> element("#subsidy-form button", "Löschen")
#         |> render_click()
#         |> follow_redirect(conn, ~p"/clubs/#{subsidy.club_id}/subsidies")

#       assert html =~ "Zuschuss erfolgreich gelöscht"
#       assert html =~ "Zuschüsse"
#       refute html =~ "some name"
#     end
#   end

#   describe "Show" do
#     setup [:create_subsidy]

#     test "displays subsidy", %{conn: conn, user: user, subsidy: subsidy} do
#       {:error, _} = live(conn, ~p"/subsidies/#{subsidy}")

#       conn = conn |> log_in_user(user)
#       {:ok, _show_live, html} = live(conn, ~p"/subsidies/#{subsidy}")

#       assert html =~ "Zuschuss:"
#       assert html =~ subsidy.name
#     end
#   end
# end

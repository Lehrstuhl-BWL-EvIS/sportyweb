# #######################################################
# NOTE:
#   The following tests can only work after a new policy
#   has been introduced for the given entity.
#   After this has been done, uncomment the code below
#   and remove this note.
# #######################################################

# defmodule SportywebWeb.TransactionLiveTest do
#   use SportywebWeb.ConnCase

#   import Phoenix.LiveViewTest
#   import Sportyweb.AccountingFixtures
#   import Sportyweb.AccountsFixtures

#   @update_attrs %{
#     payment_date: "2023-06-05" # Only allowed attribute to be updated.
#   }
#   @invalid_attrs %{
#     payment_date: "invalid"
#   }

#   setup do
#     %{user: user_fixture()}
#   end

#   defp create_transaction(_) do
#     transaction = transaction_fixture()
#     %{transaction: transaction}
#   end

#   describe "Index" do
#     setup [:create_transaction]

#     test "lists all transactions - default redirect", %{conn: conn, user: user} do
#       {:error, _} = live(conn, ~p"/transactions")

#       conn = conn |> log_in_user(user)

#       {:ok, conn} =
#         conn
#         |> live(~p"/transactions")
#         |> follow_redirect(conn, ~p"/clubs")

#       assert conn.resp_body =~ "Vereinsübersicht"
#     end

#     test "lists all transactions", %{conn: conn, user: user, transaction: transaction} do
#       {:error, _} = live(conn, ~p"/clubs/#{transaction.club_id}/transactions")

#       conn = conn |> log_in_user(user)
#       {:ok, _index_live, html} = live(conn, ~p"/clubs/#{transaction.club_id}/transactions")

#       assert html =~ "Transaktionen"
#       assert html =~ transaction.name
#     end
#   end

#   describe "New/Edit" do
#     setup [:create_transaction]

#     test "updates transaction", %{conn: conn, user: user, transaction: transaction} do
#       {:error, _} = live(conn, ~p"/transactions/#{transaction}/edit")

#       conn = conn |> log_in_user(user)
#       {:ok, edit_live, html} = live(conn, ~p"/transactions/#{transaction}/edit")

#       assert html =~ "Transaktion bearbeiten"

#       assert edit_live
#             |> form("#transaction-form", transaction: @invalid_attrs)
#             |> render_change() =~ "can&#39;t be blank"

#       {:ok, _, html} =
#         edit_live
#         |> form("#transaction-form", transaction: @update_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, ~p"/transactions/#{transaction}")

#       assert html =~ "Transaktion erfolgreich aktualisiert"
#       assert html =~ "06.05.2023"
#     end

#     test "cancels updates transaction", %{conn: conn, user: user, transaction: transaction} do
#       conn = conn |> log_in_user(user)
#       {:ok, edit_live, _html} = live(conn, ~p"/transactions/#{transaction}/edit")

#       {:ok, _, _html} =
#         edit_live
#         |> element("#transaction-form a", "Abbrechen")
#         |> render_click()
#         |> follow_redirect(conn, ~p"/transactions/#{transaction}")
#     end
#   end

#   describe "Show" do
#     setup [:create_transaction]

#     test "displays transaction", %{conn: conn, user: user, transaction: transaction} do
#       {:error, _} = live(conn, ~p"/transactions/#{transaction}")

#       conn = conn |> log_in_user(user)
#       {:ok, _show_live, html} = live(conn, ~p"/transactions/#{transaction}")

#       assert html =~ "Transaktion:"
#       assert html =~ transaction.name
#     end
#   end
# end

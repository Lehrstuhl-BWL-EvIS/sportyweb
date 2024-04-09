# #######################################################
# NOTE:
#   The following tests can only work after a new policy
#   has been introduced for the given entity.
#   After this has been done, uncomment the code below
#   and remove this note.
# #######################################################

# defmodule SportywebWeb.ContractLiveTest do
#   use SportywebWeb.ConnCase, async: true

#   import Phoenix.LiveViewTest
#   import Sportyweb.AccountsFixtures
#   import Sportyweb.LegalFixtures

#   setup do
#     user = user_fixture()
#     %{user: user}
#   end

#   defp create_contract(_) do
#     contract = contract_fixture()
#     %{contract: contract}
#   end

#   describe "Show" do
#     setup [:create_contract]

#     test "displays contract", %{conn: conn, user: user, contract: contract} do
#       {:error, _} = live(conn, ~p"/contracts/#{contract}")

#       conn = conn |> log_in_user(user)
#       {:ok, _show_live, html} = live(conn, ~p"/contracts/#{contract}")

#       assert html =~ "Vertrag"
#       assert html =~ contract.name
#     end
#   end
# end

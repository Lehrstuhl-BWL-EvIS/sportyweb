defmodule SportywebWeb.ContractLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal
  alias Sportyweb.Organization
  alias Sportyweb.Personal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@page_title}
      </.header>

      <.card>
        <.live_component
          module={SportywebWeb.ContractLive.FormComponent}
          id={@contract.id || :new}
          action={@live_action}
          contract={@contract}
          navigate={
            if @contract.id, do: ~p"/contracts/#{@contract}", else: ~p"/clubs/#{@club}/contacts"
          }
        />
      </.card>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contracts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    contract =
      Legal.get_contract!(id, [
        :club,
        :contact,
        :partner_group,
        :partner_department,
        membership: [:club, :department, :group]
      ])

    socket
    |> assign(:page_title, "Vertrag bearbeiten")
    |> assign(:club, contract.club)
    |> assign(:contract, contract)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id)

    contact =
      case params["contact"] do
        nil -> nil
        contact_id -> Personal.get_contact!(contact_id)
      end

    department =
      case params["department"] do
        nil -> nil
        department_id -> Organization.get_department!(department_id)
      end

    group =
      case params["group"] do
        nil -> nil
        group_id -> Organization.get_group!(group_id)
      end

    socket
    |> assign(:page_title, "Vertrag erstellen")
    |> assign(:club, club)
    |> assign(:contract, %Contract{
      club: club,
      club_id: club.id,
      partner_department: department,
      partner_department_id: if department == nil do nil else department.id end,
      partner_group: group,
      partner_group_id: if group == nil do nil else group.id end,
      contact: contact,
      contact_id: if contact == nil do nil else contact.id end,
      signing_date: Date.utc_today()
    })
  end
end

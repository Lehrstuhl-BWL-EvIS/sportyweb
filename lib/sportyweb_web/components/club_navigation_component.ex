defmodule SportywebWeb.ClubNavigationComponent do
  use SportywebWeb, :live_component

  @doc """
  Renders the club navigation.

  To mark the current item, the club_navigation_current_item has to be assigned
  with one of the available atoms (check below) as its value.
  This can be done in the mount function of the corresponding
  LiveView component. An easy example:

  ## Examples

      def mount(_params, _session, socket) do
        {:ok, assign(socket, :club_navigation_current_item, :dashboard)}
      end

  """
  @impl true
  def render(assigns) do
    ~H"""
    <nav class="sticky top-10">
      <div class="space-y-1">
        <.link
          navigate={~p"/clubs/#{@club}"}
          class={[
            @classes_menu_item,
            if(@club_navigation_current_item == :dashboard, do: @classes_menu_item_active)
          ]}
        >
          <.icon name="hero-rocket-launch" class={@classes_icon} />
          <span class="truncate">Dashboard</span>
        </.link>

        <.link
          navigate={~p"/clubs/#{@club}/events"}
          class={[
            @classes_menu_item,
            if(@club_navigation_current_item == :calendar, do: @classes_menu_item_active)
          ]}
        >
          <.icon name="hero-calendar" class={@classes_icon} />
          <span class="truncate">Kalender</span>
        </.link>

        <.link
          navigate={~p"/clubs/#{@club}/departments"}
          class={[
            @classes_menu_item,
            if(@club_navigation_current_item == :structure, do: @classes_menu_item_active)
          ]}
        >
          <.icon name="hero-squares-plus" class={@classes_icon} />
          <span class="truncate">Abteilungen & Gruppen</span>
        </.link>

        <.link
          navigate={~p"/clubs/#{@club}/contacts"}
          class={[
            @classes_menu_item,
            if(@club_navigation_current_item == :contacts, do: @classes_menu_item_active)
          ]}
        >
          <.icon name="hero-user-group" class={@classes_icon} />
          <span class="truncate">Kontakte & Mitglieder</span>
        </.link>

        <.link
          navigate={~p"/clubs/#{@club}/venues"}
          class={[
            @classes_menu_item,
            if(@club_navigation_current_item == :assets, do: @classes_menu_item_active)
          ]}
        >
          <.icon name="hero-building-office-2" class={@classes_icon} />
          <span class="truncate">Standorte & Equipment</span>
        </.link>

        <.link
          phx-target={@myself}
          phx-click="toggle_submenu"
          phx-value-item={:finances}
          class={[
            @classes_menu_item,
            if(@club_navigation_current_item == :finances, do: @classes_menu_item_active)
          ]}
        >
          <.icon name="hero-banknotes" class={@classes_icon} />
          <span class="truncate">Finanzen</span>
          <.icon
            name="hero-chevron-right"
            class={Enum.join([@classes_chevron, if(@show_submenu_finances, do: "rotate-90")], " ")}
          />
        </.link>

        <ul class={["mb-1 px-2", if(!@show_submenu_finances, do: "hidden")]}>
          <li>
            <.link
              navigate={~p"/clubs/#{@club}/transactions"}
              class={[
                @classes_menu_item,
                @classes_submenu_item,
                if(@club_navigation_current_item == :transactions, do: @classes_menu_item_active)
              ]}
            >
              <span class="truncate">Transaktionen</span>
            </.link>
          </li>
          <li>
            <.link
              navigate={~p"/clubs/#{@club}/forecasts"}
              class={[
                @classes_menu_item,
                @classes_submenu_item,
                if(@club_navigation_current_item == :forecasts, do: @classes_menu_item_active)
              ]}
            >
              <span class="truncate">Prognose</span>
            </.link>
          </li>
          <li>
            <.link
              navigate={~p"/clubs/#{@club}/fees"}
              class={[
                @classes_menu_item,
                @classes_submenu_item,
                if(@club_navigation_current_item == :fees, do: @classes_menu_item_active)
              ]}
            >
              <span class="truncate">Gebühren</span>
            </.link>
          </li>
          <li>
            <.link
              navigate={~p"/clubs/#{@club}/subsidies"}
              class={[
                @classes_menu_item,
                @classes_submenu_item,
                if(@club_navigation_current_item == :subsidies, do: @classes_menu_item_active)
              ]}
            >
              <span class="truncate">Zuschüsse</span>
            </.link>
          </li>
        </ul>

        <.link
          navigate={~p"/clubs/#{@club}/roles"}
          class={[
            @classes_menu_item,
            if(@club_navigation_current_item == :authorization, do: @classes_menu_item_active)
          ]}
        >
          <.icon name="hero-lock-closed" class={@classes_icon} />
          <span class="truncate">Nutzer & Rollen</span>
        </.link>
      </div>
    </nav>
    """
  end

  @impl true
  def update(assigns, socket) do
    show_submenu_finances =
      assigns.club_navigation_current_item == :transactions ||
        assigns.club_navigation_current_item == :forecasts ||
        assigns.club_navigation_current_item == :fees ||
        assigns.club_navigation_current_item == :subsidies

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :classes_menu_item,
       "text-zinc-700 hover:bg-zinc-50 group flex items-center px-3 py-2 text-base lg:text-sm font-medium rounded-md"
     )
     |> assign(:classes_menu_item_active, "bg-zinc-200 hover:bg-zinc-200")
     |> assign(:classes_submenu_item, "pl-11 text-sm font-normal")
     |> assign(:classes_icon, "text-zinc-400 group-hover:text-zinc-500 mr-4 h-6 w-6")
     |> assign(:classes_chevron, "text-zinc-600 ml-auto h-4 w-4")
     |> assign(:show_submenu_finances, show_submenu_finances)}
  end

  @impl true
  def handle_event("toggle_submenu", %{"item" => "finances"}, socket) do
    {:noreply, assign(socket, :show_submenu_finances, !socket.assigns.show_submenu_finances)}
  end
end

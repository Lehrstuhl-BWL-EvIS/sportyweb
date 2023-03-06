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
        {:ok,
         socket
         |> assign(:club_navigation_current_item, :dashboard)}
      end

  """
  @impl true
  def render(assigns) do
    assigns = assign(assigns, :default_link_classes, "text-zinc-700 hover:bg-zinc-50 group flex items-center px-3 py-2 text-base lg:text-sm font-medium rounded-md")
    assigns = assign(assigns, :current_link_classes, "bg-zinc-200")
    assigns = assign(assigns, :default_icon_classes, "text-zinc-400 group-hover:text-zinc-500 mr-4 h-6 w-6")

    ~H"""
    <nav class="sticky top-10">
      <div class="space-y-1">
        <.link navigate={~p"/clubs/#{@club}"}
        class={[@default_link_classes, (if @club_navigation_current_item == :dashboard, do: @current_link_classes)]}>
          <Heroicons.rocket_launch class={@default_icon_classes} />
          <span class="truncate">Dashboard</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}"}
        class={[@default_link_classes, (if @club_navigation_current_item == :calendar, do: @current_link_classes)]}>
          <Heroicons.calendar class={@default_icon_classes} />
          <span class="truncate">Kalender</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}/departments"}
        class={[@default_link_classes, (if @club_navigation_current_item == :structure, do: @current_link_classes)]}>
          <Heroicons.squares_plus class={@default_icon_classes} />
          <span class="truncate">Abteilungen & Gruppen</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}/contacts"}
        class={[@default_link_classes, (if @club_navigation_current_item == :contacts, do: @current_link_classes)]}>
          <Heroicons.user_group class={@default_icon_classes} />
          <span class="truncate">Kontakte & Mitglieder</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}/venues"}
        class={[@default_link_classes, (if @club_navigation_current_item == :assets, do: @current_link_classes)]}>
          <Heroicons.building_office_2 class={@default_icon_classes} />
          <span class="truncate">Standorte & Equipment</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}/fees"}
        class={[@default_link_classes, (if @club_navigation_current_item == :finances, do: @current_link_classes)]}>
          <Heroicons.banknotes class={@default_icon_classes} />
          <span class="truncate">Gebühren</span>
        </.link>

        <.link navigate={~p"/clubs/#{@club}"}
        class={[@default_link_classes, (if @club_navigation_current_item == :authentication, do: @current_link_classes)]}>
          <Heroicons.lock_closed class={@default_icon_classes} />
          <span class="truncate">Nutzer & Rollen</span>
        </.link>
      </div>
    </nav>
    """
  end
end

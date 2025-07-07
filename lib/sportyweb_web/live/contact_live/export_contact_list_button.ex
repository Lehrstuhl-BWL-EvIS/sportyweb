defmodule SportywebWeb.ContactLive.ExportContactListButton do
  use SportywebWeb, :live_component

  attr :club, :string, default: nil
  attr :only_members_of, :string, default: nil

  @impl true
  def render(assigns) do
    ~H"""
    <div class="inline-flex  max-w-[8rem] items-baseline rounded-lg bg-zinc-900 text-sm font-semibold leading-6 text-white active:text-white">
      <a href={
        get_export_link(
          @club,
          @export_with_memberships,
          @export_with_contact_groups,
          @only_members_of
        )
      }>
        <.button>
          Exportieren
        </.button>
      </a>
      <div phx-click={show_modal("export_modal")} class="rounded-lg  hover:bg-zinc-700 ">
        <.icon name="hero-funnel" />
      </div>

      <.modal id="export_modal">
        <.header level="2">
          Export einstellen
        </.header>
        <.simple_form for={%{}} phx-target={@myself} phx-change="update_export_form">
          <.input
            name="export_with_memberships"
            type="checkbox"
            label="Mitgliedschaften exportieren"
            value={@export_with_memberships}
          />

          <.input
            name="export_with_contact_groups"
            type="checkbox"
            label="Kontaktgruppen exportieren"
            value={@export_with_contact_groups}
          />
        </.simple_form>

        <.button phx-click={hide_modal("export_modal")} class="mt-5">
          Schließen
        </.button>
      </.modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    only_members_of = assigns[:only_members_of]

    socket =
      socket
      |> assign(assigns)
      |> assign(:export_with_memberships, "false")
      |> assign(:export_with_contact_groups, "false")
      |> assign(:only_members_of, only_members_of)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "update_export_form",
        %{
          "export_with_contact_groups" => export_with_contact_groups,
          "export_with_memberships" => export_with_memberships
        },
        socket
      ) do
    socket =
      socket
      |> assign(:export_with_contact_groups, export_with_contact_groups)
      |> assign(:export_with_memberships, export_with_memberships)

    {:noreply, socket}
  end

  def get_export_link(club, export_with_memberships, export_with_contact_groups, only_members_of) do
    link =
      "/clubs/#{club.id}/contacts/export?add_memberships=#{export_with_memberships}&add_contact_groups=#{export_with_contact_groups}"

    if only_members_of == nil, do: link, else: link <> "&only_members_of=#{only_members_of}"
  end
end

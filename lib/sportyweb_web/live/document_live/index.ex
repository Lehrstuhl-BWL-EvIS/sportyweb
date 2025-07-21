defmodule SportywebWeb.DocumentLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.{Organization, Documents.Document}
  alias Sportyweb.Repo
  alias SportywebWeb.DocumentLive.DocumentConfig

  alias Sportyweb.Documents.{
    ContactDocument,
    ClubDocument,
    ContractDocument,
    DepartmentDocument,
    EquipmentDocument,
    EventDocument,
    GroupDocument,
    LocationDocument
  }



  @extensions_config [

    %{key: :club_document,      title: "Verein",        component: ClubDocument},
    %{key: :department_document,title: "Abteilungen",     component: DepartmentDocument},
    %{key: :group_document,     title: "Gruppen",        component: GroupDocument},
    %{key: :location_document,  title: "Standorte",       component: LocationDocument},
    %{key: :equipment_document, title: "Equipment",      component: EquipmentDocument},
    %{key: :event_document,     title: "Veranstaltungen",component: EventDocument},
    %{key: :contact_document,   title: "Kontakte & Mitglieder",        component: ContactDocument},
    %{key: :contract_document,  title: "Verträge",       component: ContractDocument},
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :documents)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id} = params, _uri, socket) do
    docs_query = Document.for_club_query(params)

    club =
      club_id
      |> Organization.get_club!()
      |> Repo.preload(owned_documents: docs_query)

    extensions_by_type =
      club.owned_documents
      |> extract_extensions()
      |> group_extensions()

    {:noreply,
     socket
     |> assign(:page_title,         "Dokumente")
     |> assign(:club,               club)
     |> assign(:extensions_by_type, extensions_by_type)

     |> assign(:extensions_config,   @extensions_config)
     |> assign(:search_q,           Map.get(params, "q", ""))}
  end

  @impl true
  def handle_event("search", %{"q" => q}, %{assigns: %{club: club}} = socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/clubs/#{club.id}/documents?q=#{q}"
     )}
  end

  # Pull out each non‐nil extension struct and attach its parent document
  defp extract_extensions(docs) do
    for doc <- docs,
        %{key: field} <- @extensions_config,
        ext = Map.get(doc, field),
        ext != nil,
        do: %{ext | document: doc}
  end

  # Group by the extension struct’s module
  defp group_extensions(exts) do
    Enum.group_by(exts, fn
      %ContactDocument{}    -> :contact_document
      %ClubDocument{}       -> :club_document
      %ContractDocument{}   -> :contract_document
      %DepartmentDocument{} -> :department_document
      %EquipmentDocument{}  -> :equipment_document
      %EventDocument{}      -> :event_document
      %GroupDocument{}      -> :group_document
      %LocationDocument{}   -> :location_document
    end)
  end
end

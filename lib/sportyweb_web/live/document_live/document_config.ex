defmodule SportywebWeb.DocumentLive.DocumentConfig do
  @moduledoc """
  Liefert die Konfiguration für die verschiedenen Dokumenttypen.
  """

  def get_config("contact_document") do
    %{
      related_type: :contact,
      get_club: & Sportyweb.Organization.get_club!(&1.club_id),
      extension_module: Sportyweb.Documents.ContactDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Personal.get_contact!/1,
      get_entity: fn extension ->
        Sportyweb.Personal.get_contact!(extension.contact_id)
      end,
      navigate_back: fn contact ->
        "/contacts/#{contact.id}"
      end,
    }
  end

  def get_config("club_document") do
    %{
      related_type: :club,
      get_club: & &1,
      extension_module: Sportyweb.Documents.ClubDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Organization.get_club!/1,
      get_entity: fn extension ->
        Sportyweb.Organization.get_club!(extension.club_id)
      end,
      navigate_back: fn club ->
        "/clubs/#{club.id}"
      end
    }
  end

  def get_config("contract_document") do
    %{
      related_type: :contract,
      get_club: & Sportyweb.Organization.get_club!(&1.club_id),
      extension_module: Sportyweb.Documents.ContractDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Legal.get_contract!/1,
      get_entity: fn extension ->
        Sportyweb.Legal.get_contract!(extension.contract_id)
      end,
      navigate_back: fn contract ->
        "/contracts/#{contract.id}"
      end
    }
  end

  def get_config("equipment_document") do
    %{
      related_type: :equipment,
      get_club: & Sportyweb.Organization.get_club!(Sportyweb.Asset.get_location!(&1.location_id).club_id),
      extension_module: Sportyweb.Documents.EquipmentDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Asset.get_equipment!/1,
      get_entity: fn extension ->
        Sportyweb.Asset.get_equipment!(extension.equipment_id)
      end,
      navigate_back: fn equipment ->
        "/equipment/#{equipment.id}"
      end
    }
  end

  def get_config("location_document") do
    %{
      related_type: :location,
      get_club: & Sportyweb.Organization.get_club!(&1.club_id),
      extension_module: Sportyweb.Documents.LocationDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Asset.get_location!/1,
      get_entity: fn extension ->
        Sportyweb.Asset.get_location!(extension.location_id)
      end,
      navigate_back: fn location ->
        "/locations/#{location.id}"
      end
    }
  end

  def get_config("event_document") do
    %{
      related_type: :event,
      get_club: & Sportyweb.Organization.get_club!(&1.club_id),
      extension_module: Sportyweb.Documents.EventDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Calendar.get_event!/1,
      get_entity: fn extension ->
        Sportyweb.Calendar.get_event!(extension.event_id)
      end,
      navigate_back: fn event ->
        "/events/#{event.id}"
      end
    }
  end

  def get_config("department_document") do
    %{
      related_type: :department,
      get_club: & Sportyweb.Organization.get_club!(&1.club_id),
      extension_module: Sportyweb.Documents.DepartmentDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Organization.get_department!/1,
      get_entity: fn extension ->
        Sportyweb.Organization.get_department!(extension.department_id)
      end,
      navigate_back: fn department ->
        "/departments/#{department.id}"
      end
    }
  end

  def get_config("group_document") do
    %{
      related_type: :group,
      get_club: & Sportyweb.Organization.get_club!(Sportyweb.Organization.get_department!(&1.department_id).club_id),
      extension_module: Sportyweb.Documents.GroupDocument,
      form_component: SportywebWeb.TypeFormComponent,
      load_entity: &Sportyweb.Organization.get_group!/1,
      get_entity: fn extension ->
        Sportyweb.Organization.get_group!(extension.group_id)
      end,
      navigate_back: fn group ->
        "/groups/#{group.id}"
      end
    }
  end
end

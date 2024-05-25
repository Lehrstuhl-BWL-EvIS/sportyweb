defmodule Sportyweb.RBAC.Policy do
  use SportywebWeb, :verified_routes

  alias Sportyweb.Organization
  alias Sportyweb.Asset
  alias Sportyweb.Calendar
  alias Sportyweb.Finance
  alias Sportyweb.Personal

  alias Sportyweb.RBAC.UserRole
  alias Sportyweb.RBAC.Role.RolePermissionMatrix, as: RPM

  # <--- Policy on_mount hook to enforce authorization based on RBAC concept ---> #
  def on_mount(:permissions, params, _session, socket) do
    action = socket.assigns.live_action
    view = get_live_view(socket.view)

    if is_application_admin_or_tester(socket.assigns.current_user) ||
         permit?(socket.assigns.current_user, action, view, params) do
      {:cont,
       socket
       |> add_streams(view, action)
       |> add_assigns(view, action)}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "Zugriff verweigert.")
       |> Phoenix.LiveView.push_navigate(to: error_redirect(action, view, params))}
    end
  end

  defp get_live_view(view),
    do: view |> Kernel.inspect() |> String.split(".") |> Enum.at(1) |> String.to_atom()

  # <--- Policy check for application admins ---> #
  def is_application_admin_or_tester(user) do
    user
    |> UserRole.list_users_applicationroles()
    |> Enum.map(& &1.applicationrole.name)
    |> Enum.map(&RPM.to_role_atom(:application, &1))
    |> Enum.map(&Enum.member?([:admin, :tester], &1))
    |> Enum.member?(true)
  end

  # <--- Policy check for club and department role permissions ---> #
  def permit?(_user, :index, :ClubLive, _params), do: true
  def permit?(_user, :new, :ClubLive, _params), do: false

  def permit?(user, action, view, params)
      when view in [
             :ClubLive,
             :RoleLive,
             :LocationLive,
             :EventLive,
             :ContactLive,
             :FeeLive
           ] do
    club_id =
      if Map.has_key?(params, "club_id"),
        do: params["club_id"],
        else: params["id"] |> get_associated_id(view)

    is_allowed?(user.id, action, club_id, view)
  end

  def permit?(user, action, :DepartmentLive = view, params) do
    club_id =
      if Map.has_key?(params, "club_id"),
        do: params["club_id"],
        else: params["id"] |> get_associated_id(view)

    dept_id = if Map.has_key?(params, "id"), do: params["id"], else: nil
    is_allowed?(user.id, action, club_id, view, dept_id)
  end

  def permit?(user, action, :GroupLive = view, params) do
    dept_id =
      if Map.has_key?(params, "department_id"),
        do: params["department_id"],
        else: params["id"] |> get_associated_id(view)

    club_id = dept_id |> Organization.get_department!() |> Map.get(:club_id)
    is_allowed?(user.id, action, club_id, view, dept_id)
  end

  def permit?(user, action, :EquipmentLive = view, params) do
    location_id =
      if Map.has_key?(params, "location_id"),
        do: params["location_id"],
        else: params["id"] |> get_associated_id(view)

    club_id = location_id |> Asset.get_location!() |> Map.get(:club_id)
    is_allowed?(user.id, action, club_id, view)
  end

  def permit?(_user, _action, _view, _params), do: false

  defp is_allowed?(user_id, action, club_id, view, dept_id \\ nil) do
    user_roles = list_users_roles_in_club(user_id, club_id, dept_id)
    is_associated_to_club = length(user_roles) > 0

    is_associated_to_department =
      [] |> maybe_add_department_roles(user_id, club_id, dept_id) |> length() > 0

    permissions =
      [:club, :department] |> Enum.map(&RPM.role_permission_matrix(&1)) |> List.flatten()

    user_roles
    |> Enum.reduce([], fn role, acc -> acc ++ Keyword.get_values(permissions, role) end)
    |> Enum.map(&Map.get(&1, view))
    |> RPM.basic_permissions_when_associated_to_club(is_associated_to_club, view)
    |> RPM.basic_permissions_when_associated_to_department(is_associated_to_department, view)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.member?(action)
  end

  defp list_users_roles_in_club(user_id, club_id, dept_id) do
    user_id
    |> get_users_club_roles(club_id)
    |> maybe_add_department_roles(user_id, club_id, dept_id)
  end

  defp get_users_club_roles(user_id, club_id) do
    user_id
    |> UserRole.list_users_clubroles_in_a_club(club_id)
    |> Enum.map(& &1.clubrole.name)
    |> Enum.map(&RPM.to_role_atom(:club, &1))
  end

  defp maybe_add_department_roles(current_roles, user_id, club_id, nil) do
    club_id
    |> Organization.list_departments()
    |> Enum.map(&UserRole.list_users_departmentroles_in_a_department(user_id, &1.id))
    |> List.flatten()
    |> Enum.map(& &1.departmentrole.name)
    |> Enum.uniq()
    |> Enum.map(&RPM.to_role_atom(:department, &1))
    |> Kernel.++(current_roles)
  end

  defp maybe_add_department_roles(current_roles, user_id, _club_id, dept_id) do
    user_id
    |> UserRole.list_users_departmentroles_in_a_department(dept_id)
    |> Enum.map(& &1.departmentrole.name)
    |> Enum.map(&RPM.to_role_atom(:department, &1))
    |> Kernel.++(current_roles)
  end

  defp get_associated_id(id, view) when view in [:ClubLive, :RoleLive], do: id

  defp get_associated_id(id, view) do
    case view do
      :DepartmentLive -> id |> Organization.get_department!() |> Map.get(:club_id)
      :GroupLive -> id |> Organization.get_group!() |> Map.get(:department_id)
      :EventLive -> id |> Calendar.get_event!() |> Map.get(:club_id)
      :ContactLive -> id |> Personal.get_contact!() |> Map.get(:club_id)
      :LocationLive -> id |> Asset.get_location!() |> Map.get(:club_id)
      :EquipmentLive -> id |> Asset.get_equipment!() |> Map.get(:location_id)
      :FeeLive -> id |> Finance.get_fee!() |> Map.get(:club_id)
    end
  end

  # <--- Policy controlled redirect ---> #

  defp error_redirect(action, :ClubLive, _params) when action in [:new, :show], do: ~p"/clubs/"

  defp error_redirect(:index, _view, %{"club_id" => club_id}), do: ~p"/clubs/#{club_id}/"

  defp error_redirect(:index, _view, %{"department_id" => department_id}),
    do: ~p"/departments/#{department_id}/"

  defp error_redirect(:index, _view, %{"location_id" => location_id}),
    do: ~p"/locations/#{location_id}/"

  defp error_redirect(:edit, view, params), do: get_redirect_path_edit(view, params)

  defp error_redirect(action, view, params) when action in [:new, :show],
    do: get_redirect_path_new_show(view, params)

  defp error_redirect(_action, _view, _params), do: ~p"/clubs/"

  defp get_redirect_path_new_show(view, %{"id" => id}) do
    associated_id = get_associated_id(id, view)

    case view do
      :GroupLive -> get_redirect_path_new_show(view, %{"department_id" => associated_id})
      :EquipmentLive -> get_redirect_path_new_show(view, %{"location_id" => associated_id})
      _ -> get_redirect_path_new_show(view, %{"club_id" => associated_id})
    end
  end

  defp get_redirect_path_new_show(view, %{"club_id" => club_id}) do
    case view do
      :RoleLive -> ~p"/clubs/#{club_id}/roles"
      :DepartmentLive -> ~p"/clubs/#{club_id}/departments/"
      :EventLive -> ~p"/clubs/#{club_id}/events/"
      :ContactLive -> ~p"/clubs/#{club_id}/contacts"
      :LocationLive -> ~p"/clubs/#{club_id}/locations/"
      :FeeLive -> ~p"/clubs/#{club_id}/fees/"
    end
  end

  defp get_redirect_path_new_show(:GroupLive, %{"department_id" => department_id}),
    do: ~p"/departments/#{department_id}/groups/"

  defp get_redirect_path_new_show(:EquipmentLive, %{"location_id" => location_id}),
    do: ~p"/locations/#{location_id}/equipment/"

  defp get_redirect_path_edit(view, %{"id" => id}) do
    case view do
      :ClubLive -> ~p"/clubs/#{id}/"
      :DepartmentLive -> ~p"/departments/#{id}/"
      :GroupLive -> ~p"/groups/#{id}/"
      :EventLive -> ~p"/events/#{id}/"
      :ContactLive -> ~p"/contacts/#{id}/"
      :LocationLive -> ~p"/locations/#{id}/"
      :EquipmentLive -> ~p"/equipment/#{id}/"
      :FeeLive -> ~p"/fees/#{id}/"
    end
  end

  defp get_redirect_path_edit(:RoleLive, %{"club_id" => id}), do: ~p"/clubs/#{id}/roles/"

  # <--- Policy controlled buttons ---> #
  defmodule ButtonConfig, do: defstruct([:id, :index, :edit, :show, :new])

  defp get_button_config(socket, params) do
    case is_application_admin_or_tester(socket.assigns.current_user) do
      true -> %ButtonConfig{id: 1, index: true, edit: true, show: true, new: true}
      _ -> get_button_config(socket.assigns.current_user, get_live_view(socket.view), params)
    end
  end

  defp get_button_config(user, :ClubLive = view, %{} = params) do
    [index, new] = [:index, :new] |> Enum.map(&permit?(user, &1, view, params))
    %ButtonConfig{id: 1, index: index, edit: false, show: false, new: new}
  end

  defp get_button_config(user, view, params) do
    [index, edit, show, new] =
      [:index, :edit, :show, :new] |> Enum.map(&permit?(user, &1, view, params))

    %ButtonConfig{id: 1, index: index, edit: edit, show: show, new: new}
  end

  # <--- Policy streams and assigns ---> #
  defp add_streams(socket, :ClubLive, :index),
    do: Phoenix.LiveView.attach_hook(socket, :add_stream_club, :handle_params, &add_stream_club/3)

  defp add_streams(socket, _view, _action), do: socket

  defp add_assigns(socket, _view, _action),
    do:
      Phoenix.LiveView.attach_hook(
        socket,
        :add_assign_button_config,
        :handle_params,
        &add_assign_button_config/3
      )

  defp add_stream_club(_params, _url, socket) do
    socket =
      socket.assigns.current_user
      |> load_associated_clubs()
      |> Enum.reduce(socket, &Phoenix.LiveView.stream_insert(&2, :clubs, &1))

    {:cont, socket}
  end

  defp load_associated_clubs(user) do
    case is_application_admin_or_tester(user) do
      true ->
        Organization.list_clubs()

      _ ->
        Organization.list_clubs()
        |> Enum.reduce(
          [],
          &if(user_associated_with_club?(user, &1),
            do: &2 ++ [&1],
            else: &2
          )
        )
    end
  end

  defp user_associated_with_club?(user, club) do
    user.id
    |> list_users_roles_in_club(club.id, nil)
    |> length()
    |> Kernel.>(0)
  end

  defp add_assign_button_config(params, _url, socket) do
    {:cont, socket |> Phoenix.Component.assign(:button_config, get_button_config(socket, params))}
  end
end

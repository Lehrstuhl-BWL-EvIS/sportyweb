defmodule SportywebWeb.RoleLive.New do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts
  alias Sportyweb.Accounts.User
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :authorization),
     temporary_assigns: [changeset: nil]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    changeset = Accounts.change_user_registration(%User{})

    socket
    |> assign(club: Organization.get_club!(club_id))
    |> assign_form(changeset)
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("add", %{"user" => %{"email" => email}}, socket) do
    user = email |> maybe_create_user(socket)

    {:noreply,
     socket
     |> put_flash(:info, "Vergib dem Nutzer eine Rolle um ihn dem Verein hinzuzufügen.")
     |> push_navigate(to: ~p"/clubs/#{socket.assigns.club.id}/roles/#{user.id}/edit")}
  end

  defp maybe_create_user(email, socket) do
    case Accounts.get_user_by_email(email) do
      %User{} = user ->
        user

      _ ->
        Accounts.register_user_for_club(
          email,
          socket.assigns.club,
          &url(~p"/users/reset_password/#{&1}")
        )
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end

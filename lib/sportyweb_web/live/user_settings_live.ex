defmodule SportywebWeb.UserSettingsLive do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts

  def render(assigns) do
    ~H"""
    <.header>Nutzereinstellungen</.header>
    <.card>
      <%= if @current_user.confirmed_at == nil do %>
        <p class="text-red-500">Bitte bestätigen Sie ihren Account.</p>
      <% else %>
        <p class="text-green-500">Sie haben ihr Konto erfolgreich bestätigt.</p>
      <% end %>
    </.card>

    <div class="mt-10 grid grid-cols-2 gap-x-4 gap-y-12">
      <div class="col-span-2 md:col-span-1">
        <.header>E-Mail-Adresse ändern</.header>

        <.card>
          <.simple_form
            for={@email_form}
            id="email_form"
            phx-submit="update_email"
            phx-change="validate_email"
          >
            <.input field={@email_form[:email]} type="email" label="E-Mail-Adresse" required />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Aktuelles Passwort"
              value={@email_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="E-Mail-Adresse ändern...">E-Mail-Adresse ändern</.button>
            </:actions>
          </.simple_form>
        </.card>
      </div>

      <div class="col-span-2 md:col-span-1">
        <.header>Passwort ändern</.header>

        <.card>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input field={@password_form[:email]} type="hidden" value={@current_email} />
            <.input field={@password_form[:password]} type="password" label="Neues Passwort" required />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Neues Passwort"
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label="Aktuelles Passwort"
              id="current_password_for_password"
              value={@current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Passwort ändern...">Passwort ändern</.button>
            </:actions>
          </.simple_form>
        </.card>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "E-Mail-Adresse erfolgreich geändert.")

        :error ->
          put_flash(socket, :error, "Der Link zur Änderung der E-Mail-Adresse ist falsch oder abgelaufen.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "Ein Link zur Bestätigung Ihrer neuen E-Mail-Adresse wurde an die neue Adresse gesendet."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end

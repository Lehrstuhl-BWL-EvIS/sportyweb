defmodule SportywebWeb.UserConfirmationLive do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Kontobestätigung</.header>

      <.card class="mt-8">
        <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
          <.input field={@form[:token]} type="hidden" />
          <:actions>
            <.button phx-disable-with="Bestätige..." class="w-full">Mein Konto bestätigen</.button>
          </:actions>
        </.simple_form>
      </.card>

      <.live_component
        module={SportywebWeb.UserRegistrationLoginLinksComponent}
        id="user-registration-login-links"
      />
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Nutzer erfolgreich bestätigt.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "Der Link zur Kontobestätigung ist falsch oder abgelaufen.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end

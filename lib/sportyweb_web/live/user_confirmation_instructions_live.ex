defmodule SportywebWeb.UserConfirmationInstructionsLive do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts

  def render(assigns) do
    ~H"""
    <.header>Bestätigungsanweisungen erneut senden</.header>

    <.card class="mt-8">
      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" label="E-Mail-Adresse" required />
        <:actions>
          <.button phx-disable-with="Übermittle...">Bestätigungsanweisungen erneut senden</.button>
        </:actions>
      </.simple_form>
    </.card>

    <.live_component
      module={SportywebWeb.UserRegistrationLoginLinksComponent}
      id="user-registration-login-links"
    />
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.get_user_by_email("timing_attack_dummy@sportyweb.de")
      Accounts.deliver_user_confirmation_instructions(user, &url(~p"/users/reset_password/#{&1}"))
    else
      dummy = Accounts.get_user_by_email("timing_attack_dummy@sportyweb.de")
      Accounts.deliver_user_confirmation_instructions(dummy, &url(~p"/users/reset_password/#{&1}"))
    end

    info =
      "Wenn sich Ihre E-Mail-Adresse in unserem System befindet und noch nicht bestätigt wurde, werden Sie in Kürze eine E-Mail mit Anweisungen erhalten."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end

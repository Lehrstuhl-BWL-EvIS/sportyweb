defmodule SportywebWeb.UserForgotPasswordLive do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Passwort vergessen?
        <:subtitle>Wir senden Ihnen einen Link um es zurückzusetzen.</:subtitle>
      </.header>

      <.card class="mt-8">
        <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
          <.input field={@form[:email]} type="email" placeholder="E-Mail-Adresse" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Link zum Zurücksetzen anfordern
            </.button>
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.get_user_by_email("timing_attack_dummy@sportyweb.de")
      Accounts.deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
    else
      dummy = Accounts.get_user_by_email("timing_attack_dummy@sportyweb.de")
      Accounts.deliver_user_reset_password_instructions(dummy, &url(~p"/users/reset_password/#{&1}"))
    end

    info =
      "Wenn sich Ihre E-Mail-Adresse in unserem System befindet, senden wir Ihnen in Kürze die Anweisungen zu, um Ihr Passwort zurückzusetzen."

    {:noreply,
     socket
     |> put_flash(:info, info)}
  end
end

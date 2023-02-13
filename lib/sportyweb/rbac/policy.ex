defmodule Sportyweb.RBAC.Policy do

  #alias Sportyweb.RBAC.Role.RolePermissionMatrix, as: RPM

  def on_mount(:permissions, params, _session, socket) do
    user = socket.assigns.current_user.email |> String.split("@") |> Enum.at(0)
    action = socket.assigns.live_action
    view = get_live_view(socket.view)
    #dbg([user, action, view, params])
    IO.inspect([user, action, view, params])

    {:cont, socket}
    #if socket.assigns.current_user.confirmed_at do
    #  {:cont, socket}
    #else
    #  {:halt, redirect(socket, to: "/login")}
    #end
  end

  defp get_live_view(view), do: view |> Kernel.inspect() |> String.split(".") |> Enum.at(1)

end

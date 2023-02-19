defmodule SportywebWeb.Router do
  use SportywebWeb, :router

  import SportywebWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SportywebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SportywebWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", SportywebWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sportyweb, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SportywebWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SportywebWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SportywebWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SportywebWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SportywebWeb.UserAuth, :ensure_authenticated}] do

      # Users

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

    end

    live_session :rbac,
      on_mount: [{SportywebWeb.UserAuth, :ensure_authenticated}, {Sportyweb.RBAC.Policy, :permissions}] do

      # Clubs

      live "/clubs", ClubLive.Index, :index

      live "/clubs/new", ClubLive.NewEdit, :new
      live "/clubs/:id/edit", ClubLive.NewEdit, :edit

      live "/clubs/:id", ClubLive.Show, :show

      # Departments (each belongs to a club)

      live "/departments", DepartmentLive.Index, :index_root
      live "/clubs/:club_id/departments", DepartmentLive.Index, :index

      live "/clubs/:club_id/departments/new", DepartmentLive.NewEdit, :new
      live "/departments/:id/edit", DepartmentLive.NewEdit, :edit

      live "/departments/:id", DepartmentLive.Show, :show

      # Households

      live "/households", HouseholdLive.Index, :index
      live "/households/new", HouseholdLive.Index, :new
      live "/households/:id/edit", HouseholdLive.Index, :edit

      live "/households/:id", HouseholdLive.Show, :show
      live "/households/:id/show/edit", HouseholdLive.Show, :edit

      # Roles

      live "/clubs/:club_id/roles", RoleLive.Index, :index
      live "/clubs/:club_id/roles/new", RoleLive.New, :new
      live "/clubs/:club_id/roles/:user_id/edit", RoleLive.Edit, :edit

      # ApplicationRoles

      live "/applicationroles", ApplicationRoleLive.Index, :index
      live "/applicationroles/new", ApplicationRoleLive.Index, :new
      live "/applicationroles/:id/edit", ApplicationRoleLive.Index, :edit

      live "/applicationroles/:id", ApplicationRoleLive.Show, :show
      live "/applicationroles/:id/show/edit", ApplicationRoleLive.Show, :edit

      # ClubRoles

      live "/clubroles", ClubRoleLive.Index, :index
      live "/clubroles/new", ClubRoleLive.Index, :new
      live "/clubroles/:id/edit", ClubRoleLive.Index, :edit

      live "/clubroles/:id", ClubRoleLive.Show, :show
      live "/clubroles/:id/show/edit", ClubRoleLive.Show, :edit

      # UserClubRoles

      live "/clubs/:club_id/userclubroles", UserClubRoleLive.Index, :index

      live "/clubs/:club_id/userclubroles/new", UserClubRoleLive.New, :new

      live "/clubs/:club_id/userclubroles/:user_id", UserClubRoleLive.Show, :show

      # User Application Roles

      live "/userapplicationroles", UserApplicationRoleLive.Index, :index

      live "/userapplicationroles/:id", UserApplicationRoleLive.Show, :show
    end
  end

  scope "/", SportywebWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SportywebWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end

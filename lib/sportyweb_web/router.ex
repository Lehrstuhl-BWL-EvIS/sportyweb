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

      # Clubs (Root element)

      live "/clubs", ClubLive.Index, :index

      live "/clubs/new", ClubLive.NewEdit, :new
      live "/clubs/:id/edit", ClubLive.NewEdit, :edit

      live "/clubs/:id", ClubLive.Show, :show

      # Departments (Each belongs to a club)

      live "/departments", DepartmentLive.Index, :index_root
      live "/clubs/:club_id/departments", DepartmentLive.Index, :index

      live "/clubs/:club_id/departments/new", DepartmentLive.NewEdit, :new
      live "/departments/:id/edit", DepartmentLive.NewEdit, :edit

      live "/departments/:id", DepartmentLive.Show, :show

      # Groups (Each belongs to a department)

      live "/groups", GroupLive.Index, :index_root
      live "/departments/:department_id/groups", GroupLive.Index, :index

      live "/departments/:department_id/groups/new", GroupLive.NewEdit, :new
      live "/groups/:id/edit", GroupLive.NewEdit, :edit

      live "/groups/:id", GroupLive.Show, :show

      # Contacts (Each belongs to a club)

      live "/contacts", ContactLive.Index, :index
      live "/contacts/new", ContactLive.Index, :new
      live "/contacts/:id/edit", ContactLive.Index, :edit

      live "/contacts/:id", ContactLive.Show, :show
      live "/contacts/:id/show/edit", ContactLive.Show, :edit

      # Households

      live "/households", HouseholdLive.Index, :index
      live "/households/new", HouseholdLive.Index, :new
      live "/households/:id/edit", HouseholdLive.Index, :edit

      live "/households/:id", HouseholdLive.Show, :show
      live "/households/:id/show/edit", HouseholdLive.Show, :edit

      # Venues (Each belongs to a club)

      live "/venues", VenueLive.Index, :index_root
      live "/clubs/:club_id/venues", VenueLive.Index, :index

      live "/clubs/:club_id/venues/new", VenueLive.NewEdit, :new
      live "/venues/:id/edit", VenueLive.NewEdit, :edit

      live "/venues/:id", VenueLive.Show, :show

      # Equipment (Each belongs to a venue)

      live "/equipment", EquipmentLive.Index, :index_root
      live "/venues/:venue_id/equipment", EquipmentLive.Index, :index

      live "/venues/:venue_id/equipment/new", EquipmentLive.NewEdit, :new
      live "/equipment/:id/edit", EquipmentLive.NewEdit, :edit

      live "/equipment/:id", EquipmentLive.Show, :show
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

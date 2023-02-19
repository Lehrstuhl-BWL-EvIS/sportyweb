defmodule Sportyweb.AccessControl.RolePermissionMatrix do

  def role_permission_matrix(:application) do
    [
      #permissions:            []
      sportyweb_admin:         []
    ]
  end

  def role_permission_matrix(:club) do
    [
      #permissions:            [:index, :new, :edit, "delete", :show, :userrolemanagement ]
      club_admin:              [:index,  nil, :edit, "delete", :show, :userrolemanagement ],
      club_subadmin:           [:index,  nil, :edit,      nil, :show, :userrolemanagement ],
      club_readwrite_member:   [:index,  nil, :edit,      nil, :show,                 nil ],
      club_member:             [:index,  nil,   nil,      nil, :show,                 nil ]
    ]
  end

  def role_permission_matrix(:department) do
    [
      #permissions:            [:index ]
      department_admin:        [:index ],
      department_member:       [:index ]
    ]
  end

end

defmodule Sportyweb.RBACTest do
  use Sportyweb.DataCase

  alias Sportyweb.RBAC

  describe "roles" do
    alias Sportyweb.RBAC.Role

    import Sportyweb.RBACFixtures

    @invalid_attrs %{name: nil, roles: nil}

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert RBAC.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert RBAC.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      valid_attrs = %{name: "some name", roles: ["option1", "option2"]}

      assert {:ok, %Role{} = role} = RBAC.create_role(valid_attrs)
      assert role.name == "some name"
      assert role.roles == ["option1", "option2"]
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RBAC.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      update_attrs = %{name: "some updated name", roles: ["option1"]}

      assert {:ok, %Role{} = role} = RBAC.update_role(role, update_attrs)
      assert role.name == "some updated name"
      assert role.roles == ["option1"]
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = RBAC.update_role(role, @invalid_attrs)
      assert role == RBAC.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = RBAC.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> RBAC.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = RBAC.change_role(role)
    end
  end
end

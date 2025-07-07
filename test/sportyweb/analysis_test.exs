defmodule Sportyweb.AnalysisTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Group
  alias Sportyweb.Organization.Department
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Finance.Fee

  alias Sportyweb.Analysis

  import Sportyweb.FinanceFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.PersonalFixtures

  def create_contracts_and_memberships(
        %Contact{} = contact,
        %Fee{} = fee,
        organizations,
        attrs \\ %{}
      ) do
    organizations
    |> Enum.map(fn o -> create_contract(contact, o, fee, attrs) end)
    |> Enum.map(fn contract -> create_membership(contract, attrs) end)
  end

  def create_contract(contact, organization, fee, attrs \\ {})

  def create_contract(%Contact{} = contact, %Club{} = club, %Fee{} = fee, attrs) do
    {:ok, contract} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        contact_id: contact.id,
        fee_id: fee.id,
        signing_date: ~D[2023-06-01],
        start_date: ~D[2023-07-01],
        first_billing_date: nil,
        termination_date: nil,
        archive_date: nil
      })
      |> Sportyweb.Legal.create_contract("test")

    contract
  end

  def create_contract(
        %Contact{} = contact,
        %Department{} = department,
        %Fee{} = fee,
        attrs
      ) do
    {:ok, contract} =
      attrs
      |> Enum.into(%{
        club_id: department.club_id,
        department_id: department.id,
        contact_id: contact.id,
        fee_id: fee.id,
        signing_date: ~D[2023-06-01],
        start_date: ~D[2023-07-01],
        first_billing_date: nil,
        termination_date: nil,
        archive_date: nil
      })
      |> Sportyweb.Legal.create_contract("test")

    contract
  end

  def create_contract(%Contact{} = contact, %Group{} = group, %Fee{} = fee, attrs) do
    {:ok, contract} =
      attrs
      |> Enum.into(%{
        club_id: group.department.club_id,
        department_id: group.department_id,
        group_id: group.id,
        contact_id: contact.id,
        fee_id: fee.id,
        signing_date: ~D[2023-06-01],
        start_date: ~D[2023-07-01],
        first_billing_date: nil,
        termination_date: nil,
        archive_date: nil
      })
      |> Sportyweb.Legal.create_contract("test")

    contract
  end

  def create_membership(%Contract{} = contract, attrs) do
    {:ok, membership} =
      attrs
      |> Enum.into(%{
        club_id: contract.club_id,
        contact_id: contract.contact_id,
        department_id: contract.department_id,
        group_id: contract.group_id,
        contract_id: contract.id,
        state: "ACTIVE"
      })
      |> Sportyweb.Legal.create_membership("test")

    membership
  end

  def setup_club() do
    football_club = club_fixture(%{sport: "Fußball"})

    football_department =
      department_fixture(%{sport: "Fußball", name: "Abteilung Fußball"}, football_club)

    special_group =
      group_fixture(%{sport: "andere Sportart", name: "Besondere Gruppe"}, football_department)

    special_group = Map.put(special_group, :department, football_department)

    football_group = group_fixture(%{name: "Fußball Herren"}, football_department)
    football_group = Map.put(football_group, :department, football_department)

    basketball_department =
      department_fixture(%{sport: "Basketball", name: "Abteilung Basketball"}, football_club)

    default_department = department_fixture(%{}, football_club)
    fee = fee_fixture(%{}, football_club)

    male1 =
      contact_fixture(
        %{person_first_name: "male1", person_gender: "male", person_birthday: ~D[1980-02-15]},
        football_club
      )

    male2 =
      contact_fixture(
        %{person_first_name: "male2", person_gender: "male", person_birthday: ~D[1985-01-01]},
        football_club
      )

    male3 =
      contact_fixture(
        %{person_first_name: "male3", person_gender: "male", person_birthday: ~D[1985-10-31]},
        football_club
      )

    male4 =
      contact_fixture(
        %{person_first_name: "male4", person_gender: "male", person_birthday: ~D[1985-12-31]},
        football_club
      )

    female1 =
      contact_fixture(
        %{person_first_name: "female1", person_gender: "female", person_birthday: ~D[2000-02-15]},
        football_club
      )

    female2 =
      contact_fixture(
        %{person_first_name: "female2", person_gender: "female", person_birthday: ~D[1995-02-15]},
        football_club
      )

    female3 =
      contact_fixture(
        %{person_first_name: "female3", person_gender: "female", person_birthday: ~D[1991-02-15]},
        football_club
      )

    # sport of membership is football (specified by department)
    create_contracts_and_memberships(male1, fee, [
      football_club,
      football_department,
      football_group
    ])

    create_contracts_and_memberships(male2, fee, [
      football_club,
      football_department,
      football_group
    ])

    create_contracts_and_memberships(male4, fee, [football_club, default_department])
    create_contracts_and_memberships(female2, fee, [football_club, football_department])
    # sport of membership is football (specified by club)
    create_contracts_and_memberships(female3, fee, [football_club])

    # sport of membership is "andere Sportart" (specified by group)
    create_contracts_and_memberships(male2, fee, [special_group])
    create_contracts_and_memberships(female3, fee, [special_group])

    # sport of membership is "Basketball" (specified by department)
    create_contracts_and_memberships(male3, fee, [basketball_department])
    create_contracts_and_memberships(female1, fee, [basketball_department])

    # should be ignored as membership is archived
    create_contracts_and_memberships(male3, fee, [football_club, default_department], %{
      termination_date: ~D[2025-01-01],
      archive_date: ~D[2025-01-01],
      state: "TERMINATED"
    })

    football_club
  end

  def get_group(%{} = groups, group_by, group_by_value) do
    matches =
      groups.values
      |> Enum.filter(fn {{key, key_value}, _} ->
        key == group_by && key_value == group_by_value
      end)
      |> Enum.map(fn {_key, group} -> group end)

    assert 1 == Enum.count(matches)
    matches[0]
  end

  test "analyse_memberships/2 with group_bys like DOSB-analysis returns correct groups" do
    club = setup_club()

    res =
      Analysis.analyse_memberships(club.id, [
        {:sport, nil},
        {:year_of_birth, nil},
        {:gender, nil}
      ])

    {sum, groups} = res
    assert 9 == sum
    assert 3 == Enum.count(groups)

    {2, basketball_group} = Map.get(groups, {:sport, "Basketball"})
    assert 2 == Enum.count(basketball_group)
    {1, basketball_1985} = Map.get(basketball_group, {:year_of_birth, "1985"})
    assert 1 == Enum.count(basketball_1985)

    assert {1, ["male3 some person_last_name"]} ==
             get_count_and_names(basketball_1985, {:gender, "male"})

    {1, basketball_2000} = Map.get(basketball_group, {:year_of_birth, "2000"})
    assert 1 == Enum.count(basketball_2000)

    assert {1, ["female1 some person_last_name"]} ==
             get_count_and_names(basketball_2000, {:gender, "female"})

    {5, football_group} = Map.get(groups, {:sport, "Fußball"})
    assert 4 == Enum.count(football_group)
    {1, football1980} = Map.get(football_group, {:year_of_birth, "1980"})
    assert 1 == Enum.count(football1980)

    assert {1, ["male1 some person_last_name"]} ==
             get_count_and_names(football1980, {:gender, "male"})

    {2, football_1985} = Map.get(football_group, {:year_of_birth, "1985"})
    assert 1 == Enum.count(football_1985)

    assert {2, ["male2 some person_last_name", "male4 some person_last_name"]} ==
             get_count_and_names(football_1985, {:gender, "male"})

    {1, football_1991} = Map.get(football_group, {:year_of_birth, "1991"})
    assert 1 == Enum.count(football_1991)

    assert {1, ["female3 some person_last_name"]} ==
             get_count_and_names(football_1991, {:gender, "female"})

    {1, football_1995} = Map.get(football_group, {:year_of_birth, "1995"})
    assert 1 == Enum.count(football_1995)

    assert {1, ["female2 some person_last_name"]} ==
             get_count_and_names(football_1995, {:gender, "female"})

    {2, other_sports_group} = Map.get(groups, {:sport, "andere Sportart"})
    assert 2 == Enum.count(other_sports_group)
    {1, other_1985} = Map.get(other_sports_group, {:year_of_birth, "1985"})
    assert 1 == Enum.count(other_1985)

    assert {1, ["male2 some person_last_name"]} ==
             get_count_and_names(other_1985, {:gender, "male"})

    {1, other_1991} = Map.get(other_sports_group, {:year_of_birth, "1991"})
    assert 1 == Enum.count(other_1991)

    assert {1, ["female3 some person_last_name"]} ==
             get_count_and_names(other_1991, {:gender, "female"})
  end

  defp get_count_and_names(%{} = map, key) do
    entry = Map.get(map, key)
    get_count_and_names(entry)
  end

  defp get_count_and_names({count, list_of_contacts}) when is_list(list_of_contacts) do
    names =
      list_of_contacts
      |> Enum.map(fn %{id: _, name: name} -> name end)

    {count, names}
  end
end

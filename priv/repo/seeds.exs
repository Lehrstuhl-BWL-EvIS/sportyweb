# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sportyweb.Repo.insert!(%Sportyweb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Sportyweb.Repo

alias Sportyweb.Accounts
alias Sportyweb.Accounts.User
alias Sportyweb.Asset
alias Sportyweb.Asset.Equipment
alias Sportyweb.Asset.Venue
alias Sportyweb.Calendar.Event
alias Sportyweb.Finance
alias Sportyweb.Finance.Fee
alias Sportyweb.Finance.Subsidy
alias Sportyweb.Legal.Contract
alias Sportyweb.Organization
alias Sportyweb.Organization.Club
alias Sportyweb.Organization.Department
alias Sportyweb.Organization.Group
alias Sportyweb.Personal
alias Sportyweb.Personal.Contact
alias Sportyweb.Polymorphic.Email
alias Sportyweb.Polymorphic.FinancialData
alias Sportyweb.Polymorphic.InternalEvent
alias Sportyweb.Polymorphic.Note
alias Sportyweb.Polymorphic.Phone
alias Sportyweb.Polymorphic.PostalAddress

alias Sportyweb.RBAC.Role.ApplicationRole
alias Sportyweb.RBAC.Role.ClubRole
alias Sportyweb.RBAC.Role.DepartmentRole
alias Sportyweb.RBAC.Role.RolePermissionMatrix, as: RPM

###################################
# Helper functions

defmodule Sportyweb.SeedHelper do
  def get_random_string(length) do
    :crypto.strong_rand_bytes(100) |> Base.encode64() |> String.slice(0, length)
  end

  def get_random_email do
    %Email{
      type: Email.get_valid_types() |> Enum.map(fn type -> type[:value] end) |> Enum.random(),
      address: (if :rand.uniform() < 0.7, do: Faker.Internet.email(), else: "")
    }
  end

  def get_random_financial_data do
    random_name = "#{Faker.Person.last_name()}, #{Faker.Person.first_name()}"

    if :rand.uniform() < 0.9 do
      %FinancialData{
        type: "direct_debit",
        direct_debit_account_holder: random_name,
        direct_debit_iban: "DE06495352657836424132",
        direct_debit_institute: "Beispielbank"
      }
    else
      %FinancialData{
        type: "invoice",
        invoice_recipient: random_name,
        invoice_additional_information: ""
      }
    end
  end

  def get_random_internal_event do
    %InternalEvent{
      is_recurring: true,
      commission_date: ~D[2020-01-01],
      archive_date: nil,
      frequency: InternalEvent.get_valid_frequencies() |> Enum.map(fn frequency -> frequency[:value] end) |> Enum.random(),
      interval: 1
    }
  end

  def get_random_phone do
    %Phone{
      type: Phone.get_valid_types() |> Enum.map(fn type -> type[:value] end) |> Enum.random(),
      number: (if :rand.uniform() < 0.7, do: Faker.Phone.EnUs.phone(), else: "")
    }
  end

  def get_random_postal_address do
    %PostalAddress{
      street: Faker.Address.street_name(),
      street_number: Faker.Address.building_number(),
      street_additional_information: "",
      zipcode: Faker.Address.zip(),
      city: Faker.Address.city(),
      country: PostalAddress.get_valid_countries() |> Enum.map(fn country -> country[:value] end) |> Enum.random()
    }
  end

  def get_random_note do
    %Note{
      content: (if :rand.uniform() < 0.7, do: Faker.Lorem.paragraph(), else: "")
    }
  end
end

###################################
# Add Users
# Only in the dev environment!

if Mix.env() in [:dev] do
  Accounts.register_user(%{
    email: "stefan.strecker@fernuni-hagen.de",
    password: "NTU5MTM5NGNmZjY"
  })

  Accounts.register_user(%{
    email: "marvin.biesenbach@studium.fernuni-hagen.de",
    password: "MzU2OWY3NTQyNzI"
  })

  Accounts.register_user(%{
    email: "sven.christ@fernuni-hagen.de",
    password: "ZThjNWY2NTQ3OGQ"
  })

  Accounts.register_user(%{
    email: "bastian.kres@krewast.de",
    password: "MzU0MmJiZWI4ZmN"
  })

  Accounts.register_user(%{
    email: "andrew.utley@studium.fernuni-hagen.de",
    password: "MGI3MTNlMzczZjR"
  })

  Accounts.register_user(%{
    email: "TesterSportywebAdmin@test.de",
    password: "testtest"
  })

  Accounts.register_user(%{
    email: "timing_attack_dummy@sportyweb.de",
    password: "zczZjRMGI3MTNlM"
  })

  User
  |> Repo.all()
  |> Enum.map(&(Repo.update!(User.confirm_changeset(&1))))
end

###################################
# Add Club 1

club_1 = Repo.insert!(%Club{
  name: "FC Bayern München",
  reference_number: "FCB",
  description: "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin.",
  website_url: "https://fcbayern.com/",
  foundation_date: ~D[1900-02-27],
  emails: [%Email{type: "organization", address: "service@fcbayern.com"}],
  phones: [%Phone{type: "organization", number: "+49 89 699 31-0"}],
  financial_data: [Sportyweb.SeedHelper.get_random_financial_data()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

department = Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Herren",
  creation_date: ~D[1900-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Herrenmannschaft",
  creation_date: ~D[1900-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Herrenmannschaft",
  creation_date: ~D[1901-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  creation_date: ~D[1902-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  creation_date: ~D[1903-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  creation_date: ~D[1904-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

department = Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Damen",
  creation_date: ~D[1905-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [%Note{}]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Damenmannschaft",
  creation_date: ~D[1905-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Damenmannschaft",
  creation_date: ~D[1906-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  creation_date: ~D[1907-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  creation_date: ~D[1908-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  creation_date: ~D[1909-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Basketball",
  creation_date: ~D[1910-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Handball",
  creation_date: ~D[1915-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Schach",
  creation_date: ~D[1920-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

###################################
# Add Club 2

club_2 = Repo.insert!(%Club{
  name: "1. FC Köln",
  reference_number: "Effzeh",
  description: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.",
  website_url: "https://fc.de/",
  foundation_date: ~D[1948-02-13],
  emails: [%Email{type: "organization", address: "service@fc.de"}],
  phones: [%Phone{type: "organization", number: "0221 99 1948 0"}],
  financial_data: [Sportyweb.SeedHelper.get_random_financial_data()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

department = Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Herren",
  creation_date: ~D[1948-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Herrenmannschaft",
  creation_date: ~D[1948-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Herrenmannschaft",
  creation_date: ~D[1949-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  creation_date: ~D[1950-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  creation_date: ~D[1951-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  creation_date: ~D[1952-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

department = Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Damen",
  creation_date: ~D[1950-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Damenmannschaft",
  creation_date: ~D[1950-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Damenmannschaft",
  creation_date: ~D[1951-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  creation_date: ~D[1952-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  creation_date: ~D[1953-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  creation_date: ~D[1954-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Handball",
  creation_date: ~D[1955-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Tischtennis",
  creation_date: ~D[1960-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

###################################
# Add Club 3

_club_3 = Repo.insert!(%Club{
  name: "FC St. Pauli",
  reference_number: "-",
  description: "A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.",
  website_url: "https://www.fcstpauli.com/",
  foundation_date: ~D[1910-05-15],
  emails: [%Email{type: "organization", address: "info@fcstpauli.com"}],
  phones: [%Phone{type: "organization", number: "040 - 317 874 0"}],
  financial_data: [Sportyweb.SeedHelper.get_random_financial_data()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

###################################
# Add Club 4

club_4 = Repo.insert!(%Club{
  name: "Leerer Verein",
  reference_number: "",
  description: "",
  website_url: "",
  foundation_date: ~D[2020-04-01],
  emails: [%Email{type: "organization", address: ""}],
  phones: [%Phone{type: "organization", number: ""}],
  financial_data: [Sportyweb.SeedHelper.get_random_financial_data()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

###################################
# Add Club Test

testclub = Repo.insert!(%Club{
  name: "TestVerein",
  reference_number: "",
  website_url: "",
  foundation_date: ~D[2023-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  financial_data: [Sportyweb.SeedHelper.get_random_financial_data()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Department{
  club: testclub,
  name: "TestAbteilung1",
  creation_date: ~D[2023-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

Repo.insert!(%Department{
  club: testclub,
  name: "TestAbteilung2",
  creation_date: ~D[2023-03-01],
  emails: [Sportyweb.SeedHelper.get_random_email()],
  phones: [Sportyweb.SeedHelper.get_random_phone()],
  notes: [Sportyweb.SeedHelper.get_random_note()]
})

###################################
# Add Roles

for [type, struct] <- [[:application, %ApplicationRole{}], [:club, %ClubRole{}], [:department, %DepartmentRole{}]] do
  for rolename <- RPM.get_role_names(type) do
    struct |> Map.put(:name, rolename) |> Repo.insert!()
  end
end

# Seed sportyweb admins
ar = ApplicationRole
|> Repo.all()
|> Enum.filter(&(String.contains?(&1.name, "Sportyweb")))
|> Enum.at(0)

for user <- Repo.all(User) do
  Sportyweb.RBAC.UserRole.create_user_application_role(%{user_id: user.id, applicationrole_id: ar.id})
end

###################################
# Randomly generated associated data

Organization.list_clubs([departments: [:fees, groups: :fees]])
|> Enum.with_index()
|> Enum.each(fn {club, _club_index} ->
  # No data for the "empty club"!
  if club.id != club_4.id do

    # Subsidies

    subsidy = Repo.insert!(%Subsidy{
      club_id: club.id,
      name: "Zuschuss Sozialhilfeempfänger",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, 30),
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    # Fees: General - Club

    fee_pensioners = Repo.insert!(%Fee{
      club_id: club.id,
      is_general: true,
      type: "club",
      name: "Jahresmitgl. Verein Senioren",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(40..60)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 66,
      maximum_age_in_years: nil,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    fee_adults = Repo.insert!(%Fee{
      club_id: club.id,
      successor_id: fee_pensioners.id,
      is_general: true,
      type: "club",
      name: "Jahresmitgl. Verein Erwachsene (Vollmitglied)",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(60..200)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 18,
      maximum_age_in_years: 65,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    Repo.insert!(%Fee{
      club_id: club.id,
      subsidy_id: subsidy.id,
      successor_id: fee_pensioners.id,
      is_general: true,
      type: "club",
      name: "Jahresmitgl. Verein Erwachsene (Unterstützungsempfänger)",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(30..50)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 18,
      maximum_age_in_years: 65,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    fee_teenagers = Repo.insert!(%Fee{
      club_id: club.id,
      successor_id: fee_adults.id,
      is_general: true,
      type: "club",
      name: "Jahresmitgl. Verein Jugendliche",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(30..40)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 13,
      maximum_age_in_years: 17,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    Repo.insert!(%Fee{
      club_id: club.id,
      successor_id: fee_teenagers.id,
      is_general: true,
      type: "club",
      name: "Jahresmitgl. Verein Kinder",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(10..25)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 0,
      maximum_age_in_years: 12,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    # Fees: General - Departments

    fee_adults = Repo.insert!(%Fee{
      club_id: club.id,
      is_general: true,
      type: "department",
      name: "Allg. Jahresmitgl. Abteilung Erwachsene & Senioren",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(15..25)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 18,
      maximum_age_in_years: nil,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    Repo.insert!(%Fee{
      club_id: club.id,
      successor_id: fee_adults.id,
      is_general: true,
      type: "department",
      name: "Allg. Jahresmitgl. Abteilung Kinder & Jugendliche",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(5..15)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 0,
      maximum_age_in_years: 17,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    # Fees: General - Groups

    fee_adults = Repo.insert!(%Fee{
      club_id: club.id,
      is_general: true,
      type: "group",
      name: "Allg. Jahresmitgl. Gruppe Erwachsene & Senioren",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(15..25)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 18,
      maximum_age_in_years: nil,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    Repo.insert!(%Fee{
      club_id: club.id,
      successor_id: fee_adults.id,
      is_general: true,
      type: "group",
      name: "Allg. Jahresmitgl. Gruppe Kinder & Jugendliche",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(5..15)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 0,
      maximum_age_in_years: 17,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    # Fees: General - Events

    fee_adults = Repo.insert!(%Fee{
      club_id: club.id,
      is_general: true,
      type: "event",
      name: "Allg. Teilnahmegebühr Einführungskurs Fußball Erwachsene",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(25..40)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 18,
      maximum_age_in_years: 65,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    Repo.insert!(%Fee{
      club_id: club.id,
      successor_id: fee_adults.id,
      is_general: true,
      type: "event",
      name: "Allg. Teilnahmegebühr Einführungskurs Fußball Kinder",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, Enum.random(20..25)),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 0,
      maximum_age_in_years: 12,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    # Fees: General - Equipment

    Repo.insert!(%Fee{
      club_id: club.id,
      is_general: true,
      type: "equipment",
      name: "Allg. Ausleihgebühr Fußbälle",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, 3),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: nil,
      maximum_age_in_years: nil,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    Repo.insert!(%Fee{
      club_id: club.id,
      is_general: true,
      type: "equipment",
      name: "Allg. Ausleihgebühr Fußballschuhe Kinder & Jugendliche",
      reference_number: Sportyweb.SeedHelper.get_random_string(3),
      description: "",
      amount: Money.new(:EUR, 2),
      amount_one_time: Money.new(:EUR, 0),
      is_for_contact_group_contacts_only: false,
      minimum_age_in_years: 0,
      maximum_age_in_years: 17,
      internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
      notes: [%Note{}]
    })

    # Fees: Specific - Departments

    Organization.list_departments(club.id)
    |> Enum.with_index()
    |> Enum.each(fn {department, _department_index} ->
      fee_adults = Repo.insert!(%Fee{
        club_id: club.id,
        is_general: false,
        type: "department",
        name: "Spez. Jahresmitgl. Abteilung Erwachsene & Senioren",
        reference_number: Sportyweb.SeedHelper.get_random_string(3),
        description: "",
        amount: Money.new(:EUR, Enum.random(5..25)),
        amount_one_time: Money.new(:EUR, 0),
        is_for_contact_group_contacts_only: false,
        minimum_age_in_years: 18,
        maximum_age_in_years: nil,
        internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
        notes: [%Note{}],
        departments: [department]
      })

      Repo.insert!(%Fee{
        club_id: club.id,
        successor_id: fee_adults.id,
        is_general: false,
        type: "department",
        name: "Spez. Jahresmitgl. Abteilung Kinder & Jugendliche",
        reference_number: Sportyweb.SeedHelper.get_random_string(3),
        description: "",
        amount: Money.new(:EUR, Enum.random(5..10)),
        amount_one_time: Money.new(:EUR, 0),
        is_for_contact_group_contacts_only: false,
        minimum_age_in_years: 0,
        maximum_age_in_years: 17,
        internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
        notes: [%Note{}],
        departments: [department]
      })

      # Fees: Specific - Groups

      Organization.list_groups(department.id)
      |> Enum.with_index()
      |> Enum.each(fn {group, _group_index} ->
        fee_adults = Repo.insert!(%Fee{
          club_id: club.id,
          is_general: false,
          type: "group",
          name: "Spez. Jahresmitgl. Gruppe Erwachsene & Senioren",
          reference_number: Sportyweb.SeedHelper.get_random_string(3),
          description: "",
          amount: Money.new(:EUR, Enum.random(15..25)),
          amount_one_time: Money.new(:EUR, 0),
          is_for_contact_group_contacts_only: false,
          minimum_age_in_years: 18,
          maximum_age_in_years: nil,
          internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
          notes: [%Note{}],
          groups: [group]
        })

        Repo.insert!(%Fee{
          club_id: club.id,
          successor_id: fee_adults.id,
          is_general: false,
          type: "group",
          name: "Spez. Jahresmitgl. Gruppe Kinder & Jugendliche",
          reference_number: Sportyweb.SeedHelper.get_random_string(3),
          description: "",
          amount: Money.new(:EUR, Enum.random(5..15)),
          amount_one_time: Money.new(:EUR, 0),
          is_for_contact_group_contacts_only: false,
          minimum_age_in_years: 0,
          maximum_age_in_years: 17,
          internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
          notes: [%Note{}],
          groups: [group]
        })
      end)
    end)

    # Contacts & Contracts

    for _i <- 0..Enum.random(20..50) do
      # Use the context function instead of Repo.insert!() to invoke the changeset which sets the name.
      {:ok, %Contact{} = contact} = Personal.create_contact(%{
        club_id: club.id,
        type: (if :rand.uniform() < 0.8, do: "person", else: "organization"),
        organization_name: "#{Faker.Company.buzzword_prefix()} #{Faker.Industry.sub_sector()} #{Faker.Company.buzzword_prefix()}",
        organization_type: Contact.get_valid_organization_types() |> Enum.map(fn organization_type -> organization_type[:value] end) |> Enum.random(),
        person_last_name: Faker.Person.last_name(),
        person_first_name_1: Faker.Person.first_name(),
        person_first_name_2: (if :rand.uniform() < 0.80, do: "", else: Faker.Person.first_name()),
        person_gender: Contact.get_valid_genders() |> Enum.map(fn gender -> gender[:value] end) |> Enum.random(),
        person_birthday: Faker.Date.date_of_birth(6..99),
        postal_addresses: [Map.from_struct(Sportyweb.SeedHelper.get_random_postal_address())],
        emails: [Map.from_struct(Sportyweb.SeedHelper.get_random_email())],
        phones: [Map.from_struct(Sportyweb.SeedHelper.get_random_phone())],
        financial_data: [Map.from_struct(Sportyweb.SeedHelper.get_random_financial_data())],
        notes: [Map.from_struct(Sportyweb.SeedHelper.get_random_note())]
      })

      if contact.type == "person" do
        if :rand.uniform() < 0.5 do
          # Select a random fee that works with this combination of club & contact
          fee = Finance.list_contract_fee_options(club, contact.id) |> Enum.random()
          Repo.insert!(%Contract{
            club_id: club.id,
            contact_id: contact.id,
            fee_id: fee.id,
            signing_date: Date.utc_today(),
            start_date: Date.utc_today(),
            termination_date: nil,
            end_date: nil,
            clubs: [club]
          })
        end

        if Enum.any?(club.departments) do
          department = club.departments |> Enum.random()

          if :rand.uniform() < 0.3 do
            # Select a random fee that works with this combination of club & department
            fee = Finance.list_contract_fee_options(department, contact.id) |> Enum.random()
            Repo.insert!(%Contract{
              club_id: club.id,
              contact_id: contact.id,
              fee_id: fee.id,
              signing_date: Date.utc_today(),
              start_date: Date.utc_today(),
              termination_date: nil,
              end_date: nil,
              departments: [department]
            })
          end

          if Enum.any?(department.groups) do
            group = department.groups |> Enum.random()

            if :rand.uniform() < 0.3 do
              # Select a random fee that works with this combination of club & group
              fee = Finance.list_contract_fee_options(group, contact.id) |> Enum.random()
              Repo.insert!(%Contract{
                club_id: club.id,
                contact_id: contact.id,
                fee_id: fee.id,
                signing_date: Date.utc_today(),
                start_date: Date.utc_today(),
                termination_date: nil,
                end_date: nil,
                groups: [group]
              })
            end
          end
        end
      end
    end

    # Venues

    for i <- 0..Enum.random(3..7) do
      venue = Repo.insert!(%Venue{
        club_id: club.id,
        name: (if i == 0, do: "Zentrale", else: "Standort #{i + 1}"),
        reference_number: String.pad_leading("#{i + 1}", 3, "0"),
        description: (if :rand.uniform() < 0.65, do: Faker.Lorem.paragraph(), else: ""),
        postal_addresses: [Sportyweb.SeedHelper.get_random_postal_address()],
        emails: [Sportyweb.SeedHelper.get_random_email()],
        phones: [Sportyweb.SeedHelper.get_random_phone()],
        notes: [Sportyweb.SeedHelper.get_random_note()]
      })

      if i == 0, do: Organization.update_club(club, %{venue_id: venue.id})

      # Fees: Specific - Venue

      Repo.insert!(%Fee{
        club_id: club.id,
        is_general: false,
        type: "venue",
        name: "Spez. Standortmiete #{venue.reference_number}",
        reference_number: Sportyweb.SeedHelper.get_random_string(3),
        description: "",
        amount: Money.new(:EUR, Enum.random(10..150)),
        amount_one_time: Money.new(:EUR, 0),
        is_for_contact_group_contacts_only: false,
        minimum_age_in_years: nil,
        maximum_age_in_years: nil,
        internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
        notes: [%Note{}],
        venues: [venue]
      })

      # Equipment

      for _j <- 0..Enum.random(1..30) do
        equipment = Repo.insert!(%Equipment{
          venue_id: venue.id,
          name: Faker.Commerce.product_name(),
          reference_number: Sportyweb.SeedHelper.get_random_string(5),
          serial_number: Sportyweb.SeedHelper.get_random_string(15),
          description: (if :rand.uniform() < 0.50, do: Faker.Lorem.paragraph(), else: ""),
          purchase_date: Faker.Date.backward(Enum.random(300..2000)),
          commission_date: Faker.Date.backward(Enum.random(0..299)),
          decommission_date: (if :rand.uniform() < 0.65, do: Faker.Date.forward(Enum.random(100..2000)), else: nil),
          emails: [Sportyweb.SeedHelper.get_random_email()],
          phones: [Sportyweb.SeedHelper.get_random_phone()],
          notes: [Sportyweb.SeedHelper.get_random_note()]
        })

        # Fees: Specific - Equipment

        Repo.insert!(%Fee{
          club_id: club.id,
          is_general: false,
          type: "equipment",
          name: "Spez. Ausleihgebühr Equipment #{equipment.reference_number}",
          reference_number: Sportyweb.SeedHelper.get_random_string(3),
          description: "",
          amount: Money.new(:EUR, Enum.random(10..150)),
          amount_one_time: Money.new(:EUR, 0),
          is_for_contact_group_contacts_only: false,
          minimum_age_in_years: nil,
          maximum_age_in_years: nil,
          internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
          notes: [%Note{}],
          equipment: [equipment]
        })
      end
    end

    # Events

    venues = Asset.list_venues(club.id)
    for _i <- 0..Enum.random(10..30) do
      event = Repo.insert!(%Event{
        club_id: club.id,
        name: "Verans.: #{Faker.Lorem.characters(Enum.random(5..15))}",
        reference_number: Sportyweb.SeedHelper.get_random_string(5),
        status: "public",
        description: (if :rand.uniform() < 0.65, do: Faker.Lorem.paragraph(), else: ""),
        minimum_participants: 0,
        maximum_participants: Enum.random(3..40),
        minimum_age_in_years: 0,
        maximum_age_in_years: Enum.random(5..100),
        location_type: Event.get_valid_location_types() |> Enum.map(fn location_type -> location_type[:value] end) |> Enum.random(),
        location_description: (if :rand.uniform() < 0.65, do: Faker.Lorem.paragraph(), else: ""),
        venues: [venues |> Enum.random()],
        postal_addresses: [Sportyweb.SeedHelper.get_random_postal_address()],
        emails: [Sportyweb.SeedHelper.get_random_email()],
        phones: [Sportyweb.SeedHelper.get_random_phone()],
        notes: [Sportyweb.SeedHelper.get_random_note()]
      })

      # Fees: Specific - Event

      Repo.insert!(%Fee{
        club_id: club.id,
        is_general: false,
        type: "event",
        name: "Spez. Teilnahmegebühr Veranstaltung #{event.reference_number}",
        reference_number: Sportyweb.SeedHelper.get_random_string(3),
        description: "",
        amount: Money.new(:EUR, Enum.random(10..150)),
        amount_one_time: Money.new(:EUR, 0),
        is_for_contact_group_contacts_only: false,
        minimum_age_in_years: nil,
        maximum_age_in_years: nil,
        internal_events: [Sportyweb.SeedHelper.get_random_internal_event()],
        notes: [%Note{}],
        events: [event]
      })
    end
  end
end)

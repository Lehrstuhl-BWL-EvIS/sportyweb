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
alias Sportyweb.Asset.Venue
alias Sportyweb.Asset.Equipment
alias Sportyweb.Organization
alias Sportyweb.Organization.Club
alias Sportyweb.Organization.Department
alias Sportyweb.Organization.Group
alias Sportyweb.Personal
alias Sportyweb.Personal.Contact
alias Sportyweb.Polymorphic.Note

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
end

###################################
# Add Club 1

club_1 = Repo.insert!(%Club{
  name: "FC Bayern München",
  reference_number: "FCB",
  description: "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin.",
  website_url: "https://fcbayern.com/",
  founded_at: ~D[1900-02-27]
})

department = Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Herren",
  created_at: ~D[1900-03-01],
  notes: [
    %Note{content: Faker.Lorem.paragraph()},
    %Note{content: Faker.Lorem.paragraph()}
  ]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Herrenmannschaft",
  created_at: ~D[1900-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Herrenmannschaft",
  created_at: ~D[1901-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  created_at: ~D[1902-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  created_at: ~D[1903-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  created_at: ~D[1904-03-01]
})

department = Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Damen",
  created_at: ~D[1905-03-01],
  notes: [%Note{}]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Damenmannschaft",
  created_at: ~D[1905-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Damenmannschaft",
  created_at: ~D[1906-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  created_at: ~D[1907-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  created_at: ~D[1908-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  created_at: ~D[1909-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Basketball",
  created_at: ~D[1910-03-01],
  notes: [%Note{}]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Handball",
  created_at: ~D[1915-03-01],
  notes: [%Note{}]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Schach",
  created_at: ~D[1920-03-01],
  notes: [%Note{}]
})

###################################
# Add Club 2

club_2 = Repo.insert!(%Club{
  name: "1. FC Köln",
  reference_number: "Effzeh",
  description: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.",
  website_url: "https://fc.de/",
  founded_at: ~D[1948-02-13]
})

department = Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Herren",
  created_at: ~D[1948-03-01],
  notes: [
    %Note{content: Faker.Lorem.paragraph()}
  ]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Herrenmannschaft",
  created_at: ~D[1948-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Herrenmannschaft",
  created_at: ~D[1949-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  created_at: ~D[1950-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  created_at: ~D[1951-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  created_at: ~D[1952-03-01]
})

department = Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Damen",
  created_at: ~D[1950-03-01],
  notes: [%Note{}]
})

Repo.insert!(%Group{
  department: department,
  name: "1. Damenmannschaft",
  created_at: ~D[1950-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "2. Damenmannschaft",
  created_at: ~D[1951-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "A-Jugend",
  created_at: ~D[1952-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "B-Jugend",
  created_at: ~D[1953-03-01]
})

Repo.insert!(%Group{
  department: department,
  name: "Kinder",
  created_at: ~D[1954-03-01]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Handball",
  created_at: ~D[1955-03-01],
  notes: [%Note{}]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Tischtennis",
  created_at: ~D[1960-03-01],
  notes: [%Note{}]
})

###################################
# Add Club 3

club_3 = Repo.insert!(%Club{
  name: "FC St. Pauli",
  reference_number: "-",
  description: "A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.",
  website_url: "https://www.fcstpauli.com/",
  founded_at: ~D[1910-05-15]
})

###################################
# Add Club 4

club_4 = Repo.insert!(%Club{
  name: "Leerer Verein",
  reference_number: "",
  description: "",
  website_url: "",
  founded_at: ~D[2020-04-01]
})


###################################
# Randomly generated associated data

Organization.list_clubs()
|> Enum.with_index()
|> Enum.each(fn {club, index} ->
    # No data for the "empty club"!
    if club.id != club_4.id do

      # Contacts

      for i <- 0..Enum.random(10..30) do
        # Use the context function instead of Repo.insert!() to invoke the changeset which sets the name.
        Personal.create_contact(%{
          club_id: club.id,
          type: (if :rand.uniform() < 0.7, do: "person", else: "organization"),
          organization_name: "#{Faker.Company.buzzword_prefix()} #{Faker.Industry.sub_sector()} #{Faker.Company.buzzword_prefix()}",
          organization_type: Contact.get_valid_organization_types()|> Enum.map(fn organization_type -> organization_type[:value] end) |> Enum.random(),
          person_last_name: Faker.Person.last_name(),
          person_first_name_1: Faker.Person.first_name(),
          person_first_name_2: Faker.Person.first_name(),
          person_gender: Contact.get_valid_genders() |> Enum.map(fn gender -> gender[:value] end) |> Enum.random(),
          person_birthday: Faker.Date.date_of_birth(6..99)
        })
      end

      # Venues

      for i <- 0..Enum.random(3..7) do
        venue = Repo.insert!(%Venue{
          club_id: club.id,
          name: (if i == 0, do: "Zentrale", else: "Standort #{i + 1}"),
          reference_number: String.pad_leading("#{i + 1}", 3, "0"),
          description: (if :rand.uniform() < 0.65, do: Faker.Lorem.paragraph(), else: ""),
          is_main: i == 0
        })

        # Equipment

        for j <- 0..Enum.random(1..30) do
          Repo.insert!(%Equipment{
            venue_id: venue.id,
            name: Faker.Commerce.product_name(),
            reference_number: :crypto.strong_rand_bytes(50) |> Base.encode64() |> String.slice(0, 5),
            serial_number: :crypto.strong_rand_bytes(50) |> Base.encode64() |> String.slice(0, 15),
            description: (if :rand.uniform() < 0.50, do: Faker.Lorem.paragraph(), else: ""),
            purchased_at: Faker.Date.backward(Enum.random(300..2000)),
            commission_at: Faker.Date.backward(Enum.random(0..299)),
            decommission_at: (if :rand.uniform() < 0.65, do: Faker.Date.forward(Enum.random(100..2000)), else: nil)
          })
        end
      end
    end
  end)

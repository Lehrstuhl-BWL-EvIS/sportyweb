# CHANGELOG

## 0.4.0 (2024-05-24)

- Added subsystem to manage fees
- Added first rudimentary foundation for a subsystem to manage contacts/memberships
- Added first rudimentary foundation for a subsystem to manage finances
- Added more seed data
- Migrated to Phoenix 1.7.1 & LiveView 0.20.14
- Improved code reuse by implementing multiple LiveView components.
- Added Entities:
    - ContactGroup
    - Forecast
    - InternalEvent
    - Subsidy
    - Transaction
    - Lots of Join-Tables
- Renamed Entity: "Venue" -> "Location"
- Added CoreComponents: input_description, cancel_button
- Dependencies:
    - Added "Quantum" for schedulung jobs
    - Added "Money" and "Money SQL" to handle money and currencies
    - Added "Cocktail" to calculate calculate recurring dates


## 0.3.0 (2023-04-02)

- Authentication - main topics:
    - setup with phx.gen.auth and Argon2, see docs for details (https://hexdocs.pm/phoenix/mix_phx_gen_auth.html)
    - added password considerations
    - added timing attack considerations
    - translations
- Authorization - main topics:
    - scope for self-serivces of authenticated users
    - scope for club related services according to access control policies
- Access Control - main topics:
    - added role-based access control
    - added schemas and tables:
        - ApplicationRole
        - ClubRole
        - DepartmentRole
        - corresponding User join schemas and tables
    - added context modules:
        - RBAC
        - Role
        - UserRole
    - further additions:
        - Policy
        - RolePermissionMatrix
- RoleLive - LiveView for role administration:
    - list associated users and their roles (only ClubRole and DepartmentRole)
    - display generic role information
    - add and remove roles from registered users
    - allow permitted registered users to register other users
- Testing:
    - added some tests for implementation logic of the above
    - added some tests for application logic of the above
- Miscellaneous:
    - adjustments to seed file
    - restricted loading for clubs
    - added ButtonConfig struct to assigns to support hide/show of buttons based on permissions
    - updated all relevant LiveView tests to address access control needs


## 0.2.0 (2023-03-11)

- Added responsive, multi-column forms
- Added seed data based on Faker
- Migrated to Phoenix 1.7 (Final) & LiveView 0.18.16
- Added Entities:
    - Group
    - Venue
    - Equipment
    - Contact
    - FinancialData
    - PostalAddress
    - Event
    - Fee
    - Contract
    - ContractPause
    - Email
    - Phone
    - Note
    - Lots of Join-Tables
- Implemented polymorphic associations
- Added CoreComponents: input_grids, input_grid


## 0.1.0 (2023-02-09)

- Authentication
- Added script to automatically set up a uniform development environment
- Migrated to Phoenix 1.7 (Dev)
- Added Entities:
    - Club
    - Department
- Added Marketing Landingpage
- Introduction of a custom, responsive layout & design for the entire application
- Usage of separate views instead of modals
- Customized CoreComponents
- Added CoreComponent: card
- Automatically generated Documentation & Entity Relationship Diagram
- Added Credo as linter to ensure a certain amount of code consistency

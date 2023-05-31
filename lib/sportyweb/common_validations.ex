defmodule SportywebWeb.CommonValidations do
  import Ecto.Changeset

  @doc """
  Validates that the date value of field_1 is smaller or equal than field_2.
  Either field can be nil.

  Takes a custom error message as optional parameter.

  In the example below, the value of the archive_date field
  must be greater or equal than the value of the creation_date field.

  ## Examples

      changeset
      |> validate_dates_order(:creation_date, :archive_date, "Custom error")

  """
  def validate_dates_order(changeset, field_1, field_2, message \\ "Error!") do
    field_1_date_value = get_field(changeset, field_1)
    field_2_date_value = get_field(changeset, field_2)

    if field_1_date_value && field_2_date_value && Date.compare(field_2_date_value, field_1_date_value) == :lt do
      changeset
      |> add_error(field_2, message)
    else
      changeset
    end
  end

  @doc """
  Validates that the numerical value of field_1 is smaller or equal than field_2.
  Either field can be nil.

  Takes a custom error message as optional parameter.

  In the example below, the value of the max_age field
  must be greater or equal than the value of the min_age field.

  ## Examples

      changeset
      |> validate_numbers_order(:min_age, :max_age, "Custom error")

  """
  def validate_numbers_order(changeset, field_1, field_2, message \\ "Error!") do
    field_1_number_value = get_field(changeset, field_1)
    field_2_number_value = get_field(changeset, field_2)

    if field_1_number_value && field_2_number_value && field_1_number_value > field_2_number_value do
      changeset
      |> add_error(field_2, message)
    else
      changeset
    end
  end
end

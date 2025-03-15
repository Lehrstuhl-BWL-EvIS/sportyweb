defmodule Sportyweb.Documents.Storage do
  @moduledoc "Facade module to delegate storage actions to the configured backend."

  @backend Application.compile_env(:sportyweb, :storage_backend, Sportyweb.Documents.Storage.Local)

  defdelegate store_file(upload, document_id), to: @backend
  defdelegate get_file(filename), to: @backend
  defdelegate full_path(filename), to: @backend
end

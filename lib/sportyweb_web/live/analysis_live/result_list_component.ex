defmodule SportywebWeb.AnalysisLive.ResultListComponent do
  use SportywebWeb, :live_component
  import Sportyweb.Analysis.ResultHelper

  @impl true
  def render(%{:result => _} = assigns) do
    ~H"""
    <div>
      <dl class="divide-y divide-zinc-100">
        <div :for={group <- Kernel.elem(@result, 1)} class="flex gap-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/3 flex-none text-zinc-500">{translate_key(get_key(group))}</dt>
          <dd class="w-1/full text-zinc-700">{get_count(group)}</dd>
        </div>
      </dl>
    </div>
    """
  end
end

defmodule FilterDef do
@moduledoc """
A filter definition.
"""
  import FilterOptions
  defstruct mod: nil, options: []

	def new([mod: mod, options: options]) do
		%FilterDef{mod: mod, options: options}
  end

	def source(user_id) do
		filter_options = new_filter_options |> from_source(user_id)
		new mod: PropertyFilter, options: filter_options  
	end

end

defmodule FilterDef do
@moduledoc """
A filter definition.
"""
  import FilterOptions
  defstruct type: nil, options: []

	def new([type: type, options: options]) do
		%FilterDef{type: type, options: options}
  end

	def source(user_id) do
		filter_options = new_filter_options |> from_source(user_id)
		new type: PropertyFilter.type, options: filter_options  
	end

end

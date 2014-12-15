defmodule FilterOptions do
@moduledoc "The configuration options of a filter definition."

  defstruct source: nil, tags: [], locations: [], trust: false, max_elapsed: 0

	def new_filter_options() do
		%FilterOptions{}
  end

	def from_source(self, user_id) do
		%{self | source: user_id}
  end

	def tagged_with_any(self, tags) do
		%{self | tags: tags}
  end

	def located_in_any(self, locations) do
		%{self | locations: locations}
  end

  def from_trusted_sources(self) do
		%{self | trust: true}
  end

  def no_older_than(self, [secs: secs]) do
    %{self | max_elapsed: secs}
  end
  def no_older_than(self, [mins: mins]) do
    %{self | max_elapsed: mins * 60}
  end
  def no_older_than(self, [hours: hours]) do
    %{self | max_elapsed: hours * 3600}
  end
  def no_older_than(self, [days: days]) do
    %{self | max_elapsed: days * 24 * 3600}
  end

end

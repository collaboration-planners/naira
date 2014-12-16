defmodule Naira.Filter do
  use Behaviour
	use DB

	@doc "The filter's name"
	defcallback type() :: String.t

  @doc "Whether an event report passes the filter"
  defcallback passes?(filter_options :: %FilterOptions{}, event_report :: %EventReport{}, user :: %User{}) :: boolean

	def mod_from_type(type) do
		case type do
			"property" -> PropertyFilter
			_ -> nil
			# Add others here
    end
	end

end

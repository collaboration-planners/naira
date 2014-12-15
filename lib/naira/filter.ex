defmodule Naira.Filter do
  use Behaviour
	use DB

  @doc "Whether an event report passes the filter"
  defcallback passes?(filter_options :: %FilterOptions{}, event_report :: %EventReport{}, user :: %User{}) :: boolean

end

defmodule PropertyFilter do
	@moduledoc """
    A filter on the properties of event reports.
  """

	use DB
	require Logger

	@behaviour Naira.Filter

	# Behaviour implementation

	@spec passes?(%EventReport{}, %FilterOptions{}, %User{}) :: boolean
  @doc "Whether an event report passes given filter options for a given user"
	def passes?(event_report, filter_options, user) do
		passes_source?(event_report, filter_options)
		and passes_tags?(event_report, filter_options)
    and passes_location?(event_report, filter_options)
    and passes_trust?(event_report, filter_options, user)
		and passes_timeliness?(event_report, filter_options)
  end

	@spec type() :: String.t
  @doc "The type of this filter"
	def type() do
		"property"
  end

  # PRIVATE

  defp passes_source?(event_report, filter_options) do
		Logger.debug "Testing source"
		filter_source = filter_options.source
		filter_source === nil or event_report.user_id === filter_source
  end

	defp passes_tags?(event_report, filter_options) do
		Logger.debug "Testing tags"
		event_tags = event_report.tags
		filter_tags = filter_options.tags
		Enum.empty?(filter_tags) or Enum.any?(filter_tags, fn(tag) -> tag in event_tags  end)
  end

  defp passes_location?(event_report, filter_options) do
		Logger.debug "Testing location"
		event_location = event_report.location
		filter_locations = filter_options.locations
		Enum.empty?(filter_locations) or Enum.any?(filter_locations, fn(location) -> within_location?(event_location, location) end)
  end

  defp within_location?(location, enclosing_location) do
		#todo - use geolocation knowledge base
    String.downcase location == String.downcase enclosing_location
  end

	defp passes_trust?(event_report, filter_options, user) do
		Logger.debug "Testing trust"
		!filter_options.trust or event_report.user_id in user.vouchers
  end

  defp passes_timeliness?(event_report, filter_options) do
		Logger.debug "Testing timeliness"
		max_elapsed = filter_options.max_elapsed
		max_elapsed == 0 or age(event_report) <= max_elapsed
  end

	defp age(event_report) do
		Timex.Date.now(:secs) - event_report.date
	end

end

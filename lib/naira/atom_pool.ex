defmodule Naira.AtomPool do
  @moduledoc """
A pool of reusable atoms. Used to minimize the number of dynamically created atoms when there is no alternative.
"""

	@name __MODULE__

### API

	@spec start_link(non_neg_integer) :: {:ok, pid} | {:error, {:already_started, pid} | term}
	@doc "Starts a single agent that manages a pool of reusable atoms."
	def start_link(initial_pool_size) do
		Agent.start_link(fn -> init(initial_pool_size) end, [name: @name])
	end

	@spec take() :: atom
  @doc "Serves a possibly recycled atom and changes the state of the pool accordingly."
  def take() do
		Agent.get_and_update(@name, fn state -> take_atom state end)
  end

	@spec release(atom) :: :ok
  @doc "Releases an atom for eventual reuse, and changes the state of the pool accrodingly."
	def release(atom) do
		Agent.update(@name, fn state -> release_atom(atom, state) end)
	end

	@spec used?(atom) :: boolean
  @doc "Whether an atom is being used"
	def used?(atom) do
		%{used: used, unused: unused} = Agent.get(@name, &(&1))
		atom in used
  end

  @spec recycled?(atom) :: boolean
  @doc "Whether an atom is recycled"
  def recycled?(atom) do
		%{used: used, unused: unused} = Agent.get(@name, &(&1))
		atom in unused
  end

### PRIVATE

	defp init(initial_pool_size) do
		%{used: HashSet.new, unused: Enum.map(1..initial_pool_size, fn(_) -> make_atom end)} #start with a pool of unused atoms
  end

	defp take_atom(state) do
		if Enum.empty? state.unused do
			atom = make_atom
			{atom, %{state|:used => Set.put(state.used,atom)}} 
    else
			[atom|others] = state.unused
			{atom, %{state|:unused => others, :used => Set.put(state.used, atom)}}
    end
  end

  defp release_atom(atom, state) do
			%{state|:used => Set.delete(state.used, atom), :unused => Enum.concat(state.unused, [atom])}
  end

	defp make_atom() do
		String.to_atom UUID.uuid1
  end

end

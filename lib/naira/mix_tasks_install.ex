defmodule Mix.Tasks.DB.Install do
	@moduledoc """
Mix task for starting the Mnesia db
"""
  use Mix.Task
  use DB

  def run(_) do
    # This creates the mnesia schema, this has to be done on every node before
    # starting mnesia itself, the schema gets stored on disk based on the
    # `-mnesia` config, so you don't really need to create it every time.
    Amnesia.Schema.create

    # Once the schema has been created, you can start mnesia.
    Amnesia.start

		# When you call create/1 on the database, it creates a metadata table about
    # the database for various things, then iterates over the tables and creates
    # each one of them with the passed copying behaviour
    #
    # In this case it will keep a ram and disk copy on the current node.
    DB.create!(disk: [node])

    # This waits for the database to be fully created.
    DB.wait

    Amnesia.transaction do
      # ... initial data creation
			new_user = User.add("jf@collaboration-planners.com", "jf", "1234")
		  IO.puts "Added #{inspect new_user}"
			new_report = User.report_event(new_user, "Boom!")
			IO.puts "Added #{inspect new_report}"
			EventReport.set_description(new_report, "An explosion")
		  selection = EventReport.where user_id == new_user.id, select: [id, headline, description]
			reports = selection |> Amnesia.Selection.values |> Enum.map fn [id, headline, description] -> {id, headline, description} end
			IO.puts "Event reports of #{new_user.name}: #{inspect reports}"
    end

    # Stop mnesia so it can flush everything and keep the data sane.
    Amnesia.stop
		IO.puts "DB installed!"
  end
end

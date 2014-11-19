use Amnesia

defdatabase DB do

	deftable EventReport

	deftable User, [ { :id, autoincrement }, :email, :password, :name, :location, :assignments, :vouchers], type: :ordered_set, index: [:email] do
		#   @type t :: %Naira.User{}

		def add(email, name, password) do
			%User{email: email, name: name, password: password, assignments: [], vouchers: []} |> User.write
		end

		def report_event(self, headline) do
			EventReport.new(self.id, headline) |> EventReport.write
		end

	end

	deftable EventReport, [{:id, autoincrement}, :user_id, :headline, :description, :tags, :location, :date, :refs], type: :ordered_set, index: [:date]  do
		#		@type t :: %Naira.EventReport{}

		def new(user_id, headline) do
			%EventReport{user_id: user_id, headline: headline, date: Timex.Date.now, description: "", tags: [], refs: []}
		end

		def set_description(self, description) do
			%{self | description: description} |> EventReport.write
    end

  end

end

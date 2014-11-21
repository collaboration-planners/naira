use Amnesia

defdatabase DB do

	deftable EventReport

	deftable User, [ { :id, autoincrement }, :email, :password, :name, :location, :assignments, :vouchers], type: :set, index: [:email] do
		#   @type t :: %Naira.User{}

		def add(self) do
			Amnesia.transaction do
				if not exists self  do
					User.write self 
				else
          IO.puts "User with email #{self.email} already exists"
        end
			end
      self
		end

    def exists(self) do
			get(email: self.email) !== nil
    end

    def get([email: email]) do
			result = Amnesia.transaction do User.read_at(email, :email) end
			case result do
				[user] -> user
									_ -> nil
			end
    end
    def get([id: id]) do
			result = Amnesia.transaction do User.read(id) end
			case result do
				[user] -> user
									_ -> nil
			end
    end

	end

	deftable EventReport, [{:id, autoincrement}, :user_id, :headline, :description, :tags, :location, :date, :refs], type: :ordered_set, index: [:date]  do
		#		@type t :: %Naira.EventReport{}

		def add(self) do
			Amnesia.transaction do EventReport.write self end
      self
		end

  end

	deftable EventStreamDef, [{:id, autoincrement}, :foundational, :user_id, :shared, :source_streams, :filters], type: :set, index: [:user_id] do

		def add(self) do
			Amnesia.transaction do EventStreamDef.write self end
      self
	  end

    def get_all([user_id: user_id]) do
			Amnesia.transaction do EventStreamDef.read_at(user_id, :user_id) end
    end

		def is_universal(self) do
			self.user_id == 0
    end

  end

end

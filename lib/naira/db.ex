use Amnesia
require Logger

defdatabase DB do

	deftable EventReport

	deftable User, [ { :id, autoincrement }, :email, :name, :location, :assignments, :vouchers], type: :set, index: [:email] do

		def add(self) do
			Amnesia.transaction do
				if not exists self  do
					User.write self
					User.last
				else
          IO.puts "User with email #{self.email} already exists"
					nil
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
		  Amnesia.transaction do User.read(id) end
    end

		def destroy(id) do
			Amnesia.transaction do User.delete id end
    end

	end

  deftable Credentials, [{:id , autoincrement}, :user_id, :password, :api_key], type: :set, index: [:user_id, :api_key] do
		
		def set_password([user_id: user_id, password: password]) do
			self = get user_id: user_id
			if self !== nil do
				Amnesia.transaction do 
					Credentials.write %{self|:password => password} 
					:ok
				end
      else
				{:error, :not_found}
      end
	  end

    def set_api_key([user_id: user_id]) do
			self = get user_id: user_id
			if self !== nil do
				api_key = UUID.uuid1
				Amnesia.transaction do 
					Credentials.write %{self|:api_key => api_key} 
					{:ok, api_key}
				end
      else 
				{:error, :not_found}
			end
	  end

		def destroy([user_id: user_id]) do
			self = get user_id: user_id
      if self !== nil do
				Amnesia.transaction do Credentials.delete self.id end
      end
    end

		def get([user_id: user_id]) do
			result = Amnesia.transaction do Credentials.read_at(user_id, :user_id) end
      case result do
				[credentials] -> credentials
        _ -> nil
      end
    end

	  def update_password([user_id: user_id, password: new_password]) do
			credentials = get user_id: user_id
      if credentials !== nil do
				Amnesia.transaction do Credentials.write %{credentials|:password => new_password} end
				:ok
      else
        {:error, :not_found}
      end
    end	

		def key_exists?(api_key) do
			Amnesia.transaction do Credentials.read_at(api_key, :api_key) !== nil	end
	  end
		
  end

	deftable EventReport, [{:id, autoincrement}, :user_id, :headline, :description, :tags, :location, :date, :refs], type: :ordered_set, index: [:date, :user_id]  do
		#		@type t :: %Naira.EventReport{}

		def add(self) do
			Amnesia.transaction do 
				EventReport.write self
				EventReport.last
			end
		end

		def get_all() do
			Amnesia.transaction do EventReport.stream |> Enum.to_list end
		end

		def get(id) do
			Amnesia.transaction do EventReport.read id  end
    end

		def get_all(user_id) do
			Amnesia.transaction do EventReport.read_at(user_id, :user_id) end
    end

		def destroy(id) do
			Amnesia.transaction do EventReport.delete id end
    end

  end

	deftable EventStreamDef, [{:id, autoincrement}, :foundational, :user_id, :shared, :source_streams, :filters], type: :set, index: [:user_id] do

		def add(self) do
			Amnesia.transaction do 
				EventStreamDef.write self 
				EventStreamDef.last
			end
	  end

    def get_all([user_id: user_id]) do
			Amnesia.transaction do EventStreamDef.read_at(user_id, :user_id) end
    end

		def is_universal(self) do
			self.user_id == 0
    end

  end

end

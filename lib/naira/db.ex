### Definition of the Naira database tables, the structs that act as their schemas, 
### and table access functions.

use Amnesia
require Logger

defdatabase DB do

	@doc "User profile table"
	deftable User, [ { :id, autoincrement }, :email, :name, :location, :assignments, :vouchers], type: :set, index: [:email] do

		@spec add(%User{}) :: %User{} | nil
		@doc "Adds a user to the table if email is unique."
		def add(self) do
			Amnesia.transaction do
				if not exists self  do
					User.write self
					User.last
				else
          Logger.debug "User with email #{self.email} already exists"
					nil
        end
			end
      self
		end

		@spec exists(%User{}) :: boolean
		@doc "Whether a user with the same email is already stored."
    def exists(self) do
			get(email: self.email) !== nil
    end

		@spec get([email: String.t]) :: %User{} | nil
		@doc "Get the stored user, if any, with a given email."
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

		@spec destroy(non_neg_integer) :: :ok
		def destroy(id) do
			Amnesia.transaction do User.delete id end
    end

	end

	@doc "User credentials table. Holds a password and an API key."
  deftable Credentials, [{:id , autoincrement}, :user_id, :password, :api_key], type: :set, index: [:user_id, :api_key] do
		
		@spec set_password([user_id: non_neg_integer, password: String.t] ) :: :ok | {:error, :not_found}
		@doc "Updates the password of the user, if any, with a given id."
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

		@spec set_api_key([user_id: non_neg_integer]) :: {:ok, String.t} | {:error, :not_found}
		@doc "Sets or updates a user's api key."
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

		@spec destroy([user_id: non_neg_integer]) :: :ok | {:error, :not_found}
		@doc "Remove a user's credentials."
		def destroy([user_id: user_id]) do 
			Amnesia.transaction do
				self = get user_id: user_id
				if self !== nil do
				 Credentials.delete self.id 
        else
					{:error, :not_found}
				end
      end
    end

		@spec get([atom: any]) :: %Credentials{} | nil
		@doc "Get a user's credentials"
		def get([user_id: user_id]) do
			result = Amnesia.transaction do Credentials.read_at(user_id, :user_id) end
      case result do
				[credentials] -> credentials
        _ -> nil
      end
    end
		def get([api_key: api_key]) do
			result = Amnesia.transaction do Credentials.read_at(api_key, :api_key) end
      case result do
				[credentials] -> credentials
        _ -> nil
      end
		end

		@spec update_password([user_id: non_neg_integer, password: String.t]) :: :ok | {:error, :not_found}
		@doc "Update a user's password to a new given one."
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

	@doc "Event reports table"
	deftable EventReport, [{:id, autoincrement}, :user_id, :headline, :description, :tags, :location, :date, :refs], type: :ordered_set, index: [:date, :user_id]  do

		@spec add(%EventReport{}) :: %EventReport{}
		@doc "Adds an event report and returns it fully initialized."
		def add(self) do
			Amnesia.transaction do 
				EventReport.write self
				EventReport.last
			end
		end

		@spec get_all() :: [%EventReport{}]
		@doc "Get all known event reports."
		def get_all() do
			Amnesia.transaction do EventReport.stream |> Enum.to_list end
		end

		@spec get(non_neg_integer) :: %EventReport{} | nil
		@doc "Get the event report with given unique id."
		def get(id) do
			Amnesia.transaction do EventReport.read id  end
    end

		@spec get_all(non_neg_integer) :: [%EventReport{}]
		@doc "Get all event reports authored by a user with given id"
		def get_all(user_id) do
			Amnesia.transaction do EventReport.read_at(user_id, :user_id) end
    end

		@spec get_first() :: %EventReport{} | nil
		@doc "Get first event report"
		def get_first() do
				Amnesia.transaction do EventReport.first end
    end

		@spec next(%EventReport{}) :: %EventReport{} | nil
		@doc "Get next event report after given one"
		def get_next(self) do
			Amnesia.transaction do EventReport.next self end
		end

		@spec destroy(non_neg_integer) ::  :ok
		@doc "Remove an event report given its unique id."
		def destroy(id) do
			Amnesia.transaction do EventReport.delete id end
    end

  end

	@doc "An event stream definitions table."
	deftable EventStreamDef, [{:id, autoincrement}, :description, :user_id, :shared, :sub_stream_defs, :filters], type: :ordered_set, index: [:user_id, :shared] do

		@spec add(%EventStreamDef{}) :: %EventStreamDef{}
		@doc "Adds a new event stream definition. Returns it fully initialized."
		def add(self) do
			true = self.user_id > 0
			Amnesia.transaction do 
				EventStreamDef.write self 
				EventStreamDef.last
			end
	  end

		@spec destroy([id: non_neg_integer]) :: :ok | {:error, :not_found}
		@doc "Destroys the event stream def with the given id"
		def destroy([id: id]) do 
			Amnesia.transaction do
				self = get id
				if self !== nil do
				 EventStreamDef.delete self.id 
				else
				 {:error, :not_found}
				end
      end
    end

		@spec get(non_neg_integer) :: %EventStreamDef{} | nil
		@doc "Get the event stream def with a given id"
		def get(id) do
			Amnesia.transaction do EventStreamDef.read(id) end 
    end

		@spec get_all([user_id: non_neg_integer]) :: [%EventStreamDef{}]
		@doc "Get all event stream definitions authored by a user given its id."
    def get_all([user_id: user_id]) do
			Amnesia.transaction do EventStreamDef.read_at(user_id, :user_id) end
    end

		@spec get_all_shared() :: [%EventStreamDef{}]
    @doc "Get all shared event stream defs"
    def get_all_shared() do
			Amnesia.transaction do EventStreamDef.read_at(true, :shared) end
    end

		@spec universal?(%EventStreamDef{}) :: boolean
		@doc "Whether an event stream definition is the universal (empty) one."
		def universal?(self) do
			self.user_id == 1 and self.sub_stream_defs == [] and self.filters == []
    end

  end

end

# Naira

Naira is a microservice for event reporting and streaming that relies on 
trusted networks of sources. It can be extended via plugins.

Naira is implemented in Elixir.

Naira means _"big eyes"_ in the Quechua and Aymara (Native American) languages.

## Status
Naira is in early development

## Use Cases

### About users
* User joins the service
   * Sets email as user id and password
* User leaves the service
* User profiles self
   * Full name
   * Location
   * Assignments
      * Title
      * Organization
* User vouches for another user’s...
   * Identity
   * Individual assignments
* User browses/searches for registered users
   * By location
   * By assignments
   * By trust (trusted vs implicitly/explicitly not trusted)
      * Trust is transitive except when explicitly (and privately) not trusted
* User selects another user from list of browsed users or as source of viewed event and 
   * Sees 
      * All streams shared by that user
      * Who vouched for that user
      * Who the user vouched for
      * Activity metrics for that user
   * Requests trust voucher from that user
   * Vouches for that user (explicitly trusts the user) 
      * Thus implicitly trusting who he/she trusts (trust is transitive)
         * Unless he/she *privately* flags an implicitly trusted user as untrusted 
   * Privately flags user as not trusted
   * * User downloads settings (profile, stream, viewer and dashboard definitions) as JSON
* User updates settings from JSON

###About events
* User reports an event 
   * Defined by
      * Headline
      * Description
      * and attributes
         * Location
         * Time
         * Tags
            * To classify the event
         * References
            * URLs
   * The user reporting an event is the event’s source
   * The event report is added to the user’s stream and to the Universal stream (see below)
* User adds metadata to any event (with user id and timestamp)
   * Metadata
      * Like vs dislike (I like/dislike that it happened)
      * Confirmed vs dismissed
      * Set/unset flags
         * Actionable
         * Ended
   * Any event to which the user adds metadata is added to the user’s event stream event though the user is not necessarily the source
* Naira-sourced events (Naira is the source)
   * User joined
   * User left
   * User changed his/her profile
   * User vouched for another
   * Event stream was shared
   * User (un)subscribed from/to stream
   * Shared stream was modified
   * Dashboard shared (see below)
   * Shared dashboard modified
###About streams
* User can subscribe to all built-in streams , namely
   * Universal stream - all events reported in Naira (subscribed by default)
   * Naira stream - events with Naira as the source (subscribed by default)
   * User stream - one per user
      * Events reported, liked, confirmed or dismissed by the user
   * Trends stream (trending likes and dislikes from the Universal stream - subscribed by default)
* User authors a named stream
   * The new stream is owned, named and described by its author
      * Has history of timestamped changes, including creation
      * Is private until shared
   * The authored stream is configured by...
      * Forking a stream (copying another stream’s definition)
      * Filtering another, accessible stream
         * On tags (kinds of events)
         * On location
         * On trust (only events from trusted sources)
         * On timeliness (old events are dropped)
      * Combining two accessible streams (union)
      * Training the stream using a stream trainer (default trainer or plugin trainer)
         * Include this event (and others like it)
         * Exclude this event (and others like it)
      * Defining a complex events stream
         * Name, description
         * Input stream(s)
         * Window duration
         * Trend events 
            * within a moving window (each accepted event creates a new window)
            * Metrics
               * > N, > +delta or > -delta
               * Likes vs dislikes (ratio > R and > N opinions)
            * New window created with each accepted event
            * Each window is closed after duration
         * Synthesis events
            * Each collapses into one event all events passing the filter within a time window
               * window initially closed
               * window created with first event filtered after window closed
               * window closed when duration elapsed
            * The collapsed event is the first event
               * Other events considered alternate versions of it 
      * By integrating an external event generator via a connector
* User shares a stream definition he/she authored
* User unshares or deletes a stream
   * Subscribers automatically fork the stream and now each have their own copies of the stream
* User browses/searches for event stream definitions
   * By ownership
      * Mine vs others
      * From trusted sources only
   * By filter attributes
   * Subscribed to vs not
* User (un)subscribes from/to someone else’s stream definition
   * Subscribed-to stream definition might be changed/unshared/deleted by its author at any time
* User directs a stream to an event sink
   * Email event sink
      * His email address
         * Collating events for a time period
         * One event, one email
   * Twitter event sink
      * Events sent as Twitter message box or tweets
   * Some other external event sink via plugin
### About stream viewers and dashboards
* User sets up event stream viewers
   * Selects an owned or subscribed-to stream
   * Sets visibility window (last minute, hour, day, week,... forever)
   * Cycling Ticker vs Timeline vs Map vs Analytics
* User sets up dashboards of viewers
   * Name, description of dashboard
   * Configuration of event stream viewers
* User selects  the current dashboard
* User shares dashboards
* User subscribes to a shared dashboard
* User copies a shared dashboard as his/her own

#Plugins
* External event source connectors (input)
* External event sink connectors (output)
* Stream trainers
* Stream viewers
* Dashboard viewers

#API
## REST Resources
* User
* Event report
* Event stream
* Dashboard


## Notifications
* Subscribe to a stream
* External app receives events as JSON-encoded notifications while subscribed to an event stream

## Starting Naira

The first time you run Naira you will need to initialize the database using `mix DB.Install`.
To re-initialize the DB, do `mix DB.Unistall`

You also need to set the following environment variables:
* NAIRA_SMTP_SERVER -- e.g. imap.googlemail.com
* NAIRA_SMTP_LOGIN  -- e.g. account@example.com
* NAIRA_SMTP_PASSWORD -- e.g. password1234

Then start Phoenix router with `mix phoenix.start`
Alternately, to retain control of the terminal (to start an observer etc.), do `iex -S mix` then, in iex, do `Naira.start_phoenix`

Now you can visit `localhost:4000` from your browser.

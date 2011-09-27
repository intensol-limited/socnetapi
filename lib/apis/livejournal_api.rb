require 'livejournal/entry'   
require 'livejournal/friends' 
require 'livejournal/login' 
require 'livejournal/sync'


module Socnetapi
  class LivejournalApi
    def initialize(params = {})
      raise Socnetapi::Error::NotConnected unless params[:password]
      
      @username = params[:login]
      @password = params[:password]
      @user = LiveJournal::User.new(@username, @password)
      @session = LiveJournal::Request::SessionGenerate.new(@user)
      @session.run
    end
    
    # Get all entries. Pass a +limit+ to only get that many (the most recent).
    def get_entries(limit = nil)
      limit ||= -1
      prepare_entries(LiveJournal::Request::GetFriendsPage.new(@user, :recent => limit, :strict => false).run)
    end
    
    # Get the LiveJournal::Entry with a given id.
    def get_entry(id)
      prepare_entry(LiveJournal::Request::GetEvents.new(@user, :itemid => id, :strict => false).run || raise("There is no entry with that id."))
    end
    
    # Get the LiveJournal::Entry with a given id.
    def entry(id)
      LiveJournal::Request::GetEvents.new(@user, :itemid => id, :strict => false).run || raise("There is no entry with that id.")
    end
    
    # Get the LiveJournal URL (e.g. http://foo.livejournal.com/123.html) for the entry with a given id.
    def url(id)
      entry(id).url(@user)
    end
    
    # Pass a hash of properties to create an entry. The :body is required. If you don't set
    # a :subject, a date string like "Jan. 1st, 2009" will be used.
    def create(properties = {})
      entry = LiveJournal::Entry.new
      properties[:time] ||= Time.now
      properties[:event] ||= properties[:body]
      unless properties[:event]
        raise BodyRequired, "You must pass a :body."
      end
      assign_properties(entry, properties)
      LiveJournal::Request::PostEvent.new(@user, entry).run
      entry.itemid
    end
    
    # Pass the id of an entry and a hash of properties to update them.
    # Anything you don't pass is not changed. Pass a block for more power.
    # If the block returns false (but not nil), the +properties+ are not assigned.
    # The entry.time will always be in GMT, so use +Time.gm+ for time comparisons.
    #   lj.update(1, :subject => "New") {|entry| entry.body = entry.body.gsub('x', 'y') }
    #   lj.update(1, :security => :private) {|entry| entry.time < Time.gm(2005) }
    def update(id, properties={}, &block)
      entry = entry(id)
      assign_properties(entry, properties)
      if block_given?
        b = block.call(entry)
        return if b == false
      end
      LiveJournal::Request::EditEvent.new(@user, entry).run
      entry.itemid
    end
    
    def delete(id)
      LiveJournal::Request::EditEvent.new(@user, entry(id), :delete => true).run
    end
    
    def friends
      prepare_friends(LiveJournal::Request::Friends.new(@user, :include_friendofs => false).run)
    end
    
    private
    
      def prepare_entry post
        p post
         {
           id: post.itemid,
           author: {
             id: post.postername,
             group: post.journalname,
             nickname: post.postername
           },
           title: post.subject,
           text: post.event_as_html,
           url: "http://#{post.journalname ? post.journalname.gsub(/_/, '-') : 'unknown'}.livejournal.com/#{post.itemid}.html",
           created_at: post.time
         }
      end
      
      def prepare_entries entries
        entries.map do |k, e|
          prepare_entry(e)
        end
      end
      
      def prepare_friends friends
        friends.map do |friend|
          {
            name: friend.fullname,
            nickname: friend.username
          }
        end
      end
    
    protected

        def assign_properties(entry, properties)
          # So LJ doesn't complain about entries out of time. Entries are backdated
          # if the :time is set to something other than the previous value or the
          # current time (with a grace period of +/- one minute to account for delays
          # and for LJ rounding to full minutes). If this logic doesn't work for
          # you, explicitly pass a :backdated bool and that will be respected.
          if properties[:time]
            properties[:time] = LiveJournal.coerce_gmt(properties[:time])

            unless properties.has_key?(:backdated)
              now = LiveJournal.coerce_gmt(properties.delete(:now) || Time.now)
              expected_time = entry.time || now
              unless expected_time-60 < properties[:time] && properties[:time] <= expected_time+60  # grace period
                properties[:backdated] = true
              end
            end
          end

          if properties.has_key?(:body)
            properties[:preformatted] ||= true
          end

          properties.each do |key, value|
            m = "#{key}="
            if entry.respond_to?(m)
              entry.send(m, value)
            else
              # raise NoSuchProperty, %{Entries don't have the "#{key}" property.}
            end
          end
        end
    
  end
end

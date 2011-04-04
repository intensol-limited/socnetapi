Socnetapi 
=========

Social Networks API combiner

Usage
-----

    twitter = Socnetapi::TwitterApi.new(:token => "...", :token_secret => "...")
    twitter.get_entries # returns array of "entries" (see Entry)
    twitter.get_entry(entry_id) # returns Entry
    twitter.create(:body => "...")
    twitter.update(entry_id, :body => "...")
    twitter.delete(entry_id)
    twitter.friends # returns array of friends (see Friend)

Entry
-----

    {
      id: string,
      author: {
        id: string,
        name: string,
        nickname: string
      },
      title: string,
      text: text,
      attachments: {
        images: array of urls
      },
      url: string,
      created_at: datetime
    }
    
Friend
______

    {
      id: string,
      name: string,
      userpic: string,
      nickname: string
    }

Services
--------

    √ Facebook
    √ Flickr
    √ LiveJournal
    √ Twitter
    √ Youtube
    - Github
    - Vimeo
    - Myspace
    - Photobucket
    - Buzz
    - Wordpress
    - Blogger
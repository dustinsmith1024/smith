class Post

  FlickRaw.api_key="cca4e5c768a106ef85d2a19e22f8222d"
  FlickRaw.shared_secret="8a7e63e250a887fe"

  def list
  list   = flickr.photos.getRecent

  id     = list[0].id
  secret = list[0].secret
  info = flickr.photos.getInfo :photo_id => id, :secret => secret

  info.title           # => "PICT986"
  info.dates.taken     # => "2006-07-06 15:16:18"

  sizes = flickr.photos.getSizes :photo_id => id

  original = sizes.find {|s| s.label == 'Original' }
  original.width       # => "800"

end

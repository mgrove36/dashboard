require 'net/http'
require 'json'
require 'open-uri'

placeholder = '/assets/nyantocat.gif'

SCHEDULER.every '1h', first_in: 0 do |job|
#   uri = URI('https://www.reddit.com/r/aww.json')
#   response = Net::HTTP.get(uri)
  response = URI.parse("https://www.reddit.com/r/aww.json").read
#   puts(response)
  json = JSON.parse(response)

  if json['data']['children'].count <= 0
    send_event('aww', image: placeholder)
  else
    urls = json['data']['children'].map{|child| child['data']['url'] }

    # Ensure we're linking directly to an image, not a gallery etc.
    valid_urls = urls.select{|url| url.downcase.end_with?('png', 'gif', 'jpg', 'jpeg')}
    send_event('aww', image: "background-image:url(#{valid_urls.sample(1).first})")
  end
end
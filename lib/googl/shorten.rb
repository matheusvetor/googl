module Googl
  class Shorten < Base
    include Googl::Utils

    attr_accessor :short_url, :long_url

    # Creates a new short URL, see Googl.shorten
    #
    def initialize(long_url, user_ip = nil, api_key = nil)
      modify_headers('Content-Type' => 'application/json')
      options = { 'longUrl' => long_url }
      shorten_url = API_URL

      options['userIp'] = user_ip unless user_ip.nil? || user_ip.empty?

      shorten_url << "?key=#{api_key}" unless api_key.nil? || api_key.empty?

      options_json = options.to_json
      resp = post(shorten_url, body: options_json)

      raise exception(resp.parsed_response) unless resp.code.eql?(200)

      self.short_url  = resp['id']
      self.long_url   = resp['longUrl']
    end
  end
end

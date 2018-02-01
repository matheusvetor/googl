module Googl
  class Expand < Base
    include Googl::Utils

    attr_accessor :long_url, :analytics, :status, :short_url, :created

    # Expands a short URL or gets creation time and analytics. See Googl.expand
    #
    def initialize(options={})
      options.delete_if { |key, value| value.nil? }

      resp = get(API_URL, query: options)
      raise exception("#{resp.code} #{resp.message}") unless resp.code.eql?(200)

      self.created    = resp['created'] if resp.key?('created')
      self.long_url   = resp['longUrl']
      self.analytics  = resp['analytics'].to_openstruct if resp.key?('analytics')
      self.status     = resp['status']
      self.short_url  = resp['id']
    end
  end
end

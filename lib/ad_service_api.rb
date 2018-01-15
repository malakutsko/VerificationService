# frozen_string_literal: true

require 'json'
require 'net/http'

class AdServiceApi
  def self.request(ref_ids)
    uri = URI('http://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df')

    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = ref_ids.to_json

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    JSON.parse(res.body)['ads']
  end
end

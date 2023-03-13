require 'net/http'

module Bitly
  API_BASE_URL = 'https://api-ssl.bitly.com/v4/'

  # 汎用APIcall
  def call(method: :post, path: "", params: nil)
    uri = URI.join(API_BASE_URL, path)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri.path)
    req["authorization"] = "Bearer #{ Rails.application.credentials.dig(:bitly, :access_token) }"
    req["content-type"] = 'application/json'
    req.body = params.to_json if params

    res = JSON.parse(http.request(req).body)
    if res["errors"].present?
      error = res["errors"].map{|m| m["message"] }.join(", ")
      raise error
    elsif res["message"] == 'FORBIDDEN'
      raise 'forbidden'
    else
      Rails.logger.info "[Bitly] #{method} #{path}"
      res["link"]
    end
  rescue => error
    Rails.logger.error "[Bitly] #{method} #{path}, Error: #{error}"
    nil
  end

  module_function :call
end

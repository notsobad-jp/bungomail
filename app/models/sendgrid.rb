module Sendgrid
  API_BASE_URL = 'https://api.sendgrid.com/v3/'

  # 汎用APIcall
  def call(method: :post, path: "", params: nil)
    uri = URI.join(API_BASE_URL, path)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri.path)
    req["authorization"] = "Bearer #{ENV['SENDGRID_API_KEY']}"
    req["content-type"] = 'application/json'
    req.body = params.to_json if params

    res = (body = http.request(req).body) ? JSON.parse(body) : nil
    if res && res["errors"]
      error = res["errors"].map{|m| m["message"] }.join(", ")
      Rails.logger.error "[Sendgrid] #{method} #{path}, Error: #{error}"
      raise error
    else
      Rails.logger.info "[Sendgrid] #{method} #{path}"
      res
    end
  end
end

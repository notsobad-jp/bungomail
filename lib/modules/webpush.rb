require 'googleauth'
require 'net/http'

module Webpush
  module_function

  def notify(body)
    authorizer = authorize_firebase

    uri = URI.parse("https://fcm.googleapis.com/v1/projects/#{authorizer.project_id}/messages:send")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Authorization'] = "Bearer #{authorizer.access_token}"
    req['Content-Type'] = "application/json"
    req.body = body.to_json
    res = http.request(req)
    res.value # raise error if not 2xx
  end

  # functions経由でtopic購読するためのラッパーメソッド
  def subscribe_to_topic!(token:, topic:)
    endpoint = Rails.application.credentials.dig(:function_endpoints, :subscribe)
    res = http_get_request(endpoint, { token: token, topic: topic })
    res.value
  end

  def unsubscribe_from_topic!(token:, topic:)
    endpoint = Rails.application.credentials.dig(:function_endpoints, :unsubscribe)
    res = http_get_request(endpoint, { token: token, topic: topic })
    res.value
  end

  def authorize_firebase
    gcs_credentials = StringIO.new(Rails.application.credentials.gcs.to_json)
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: gcs_credentials,
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    )
    authorizer.fetch_access_token!
    authorizer
  end
  private_class_method :authorize_firebase

  def http_get_request(endpoint, params)
    uri = URI.parse(endpoint)
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Get.new uri.request_uri
    req['Content-Type'] = "application/json"
    http.request(req)
  end
  private_class_method :http_get_request
end

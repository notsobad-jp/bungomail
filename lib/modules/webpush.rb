require 'googleauth'
require 'net/http'

module Webpush
  module_function

  def call(body)
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
end

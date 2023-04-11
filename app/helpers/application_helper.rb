module ApplicationHelper
  def vapid_key_decoded
    Base64.urlsafe_decode64(Rails.application.credentials.dig(:vapid, :public_key))
  end
end

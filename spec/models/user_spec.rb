require 'rails_helper'

RSpec.describe User, type: :model do
  # 退会時は全削除してEmailDigestだけ残る
  describe "cancel membership" do
    let(:user) { create(:user) }

    it "should leave EmailDigest" do
      email_digest = EmailDigest.find_by(digest: user.digest)
      user.destroy
      expect(User.exists?(user.id)).to be_falsy
      expect(EmailDigest.exists?(email_digest.id)).to be_truthy
    end

    it "should update EmailDigest canceled_at" do
      email_digest = EmailDigest.find_by(digest: user.digest)
      expect{user.destroy}.to change{email_digest.reload.canceled_at}.from(nil).to(Time)
    end
  end
end

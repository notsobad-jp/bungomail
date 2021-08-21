require 'rails_helper'

RSpec.describe User, type: :model do
  # 退会時は全削除してEmailDigestだけ残る
  describe "cancel membership" do
    let(:user) { create(:user) }

    it "should leave EmailDigest" do
      email_digest = EmailDigest.find_by(digest: user.digest)
      user.destroy
      expect(User.exists?(user.id)).to be_falsy
      expect(EmailDigest.where(digest: email_digest.digest).exists?).to be_truthy
    end

    it "should update EmailDigest canceled_at" do
      email_digest = EmailDigest.find_by(digest: user.digest)
      expect{user.destroy}.to change{email_digest.reload.canceled_at}.from(nil).to(Time)
    end
  end

  # Email変更時にEmailDigestも更新する
  describe "update email" do
    let(:user) { create(:user) }

    context "when email changed" do
      it "should update EmailDigest" do
        old_digest = user.digest
        user.update(email: "changed-#{user.email}")
        expect(EmailDigest.where(digest: old_digest).exists?).to be_falsy
        expect(EmailDigest.where(digest: user.digest).exists?).to be_truthy
      end
    end
  end
end

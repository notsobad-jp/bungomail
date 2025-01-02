require 'rails_helper'

RSpec.describe User, type: :model do
  describe "cancel membership" do
    let(:user) { create(:user) }

    it "should destroy user" do
      user.destroy
      expect(User.exists?(user.id)).to be_falsy
    end
  end
end

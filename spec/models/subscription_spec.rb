require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe "check_channel_required_plan" do
    subject { user.subscriptions.create(channel_id: Channel.find_by(code: 'bungomail-official').id) }

    context "when user is free plan" do
      let!(:user) { create(:user, :with_free_membership) }

      it "should succeed to subscribe juvenile-channel" do
        expect{user.subscriptions.create(channel_id: Channel.find_by(code: 'juvenile').id)}.to change{Subscription.count}.by(1)
      end

      it "should fail to subscribe official-channel" do
        sub = subject
        expect(sub.errors.full_messages.first).to include("Basicプランへの登録")
      end
    end

    context "when user is trialing basic plan" do
      let!(:user) { create(:user, :with_trialing_membership) }

      it "should succeed" do
        expect{subject}.to change{Subscription.count}.by(1)
      end
    end

    context "when user is basic plan" do
      let!(:user) { create(:user, :with_basic_membership) }

      it "should succeed" do
        expect{subject}.to change{Subscription.count}.by(1)
      end
    end
  end

  describe "check_subscriptions_count" do
    let(:pub_channel) { create(:channel, :with_channel_profile, code: 'public') }
    subject { user.subscriptions.create(channel_id: pub_channel.id) }

    context "when user is free plan" do
      context "with no subscription" do
        let!(:user) { create(:user, :with_free_membership) }

        it "should succeed" do
          expect{subject}.to change{Subscription.count}.by(1)
        end
      end

      context "with 1 subscription" do
        let!(:user) { create(:user, :with_free_membership, :with_juvenile_sub) }

        it "should fail" do
          sub = subject
          expect(sub.errors.full_messages.first).to include("購読上限数")
        end
      end
    end

    context "when user is basic plan" do
      context "with 2 subscriptions" do
        let!(:user) { create(:user, :with_basic_membership, :with_juvenile_sub, :with_official_sub) }

        it "should succeed" do
          expect{subject}.to change{Subscription.count}.by(1)
        end
      end

      context "with   5 subscriptions" do
        let!(:user) { create(:user, :with_basic_membership, :with_juvenile_sub, :with_official_sub) }

        before do
          subs = []
          channels = create_list(:channel, 3, :with_channel_profile)
          channels.each do |c|
            subs << { user_id: user.id, channel_id: c.id }
          end
          Subscription.insert_all(subs)
        end

        it "should fail" do
          sub = subject
          expect(sub.errors.full_messages.first).to include("購読上限数")
        end
      end
    end
  end

  # Insert Member to Google Group
  describe "insert_google_member" do
    context "when google_group_key exists" do
      context "with valid & non-existing email" do
        let(:subscription) { create(:subscription, channel: create(:channel, :with_google_group, code: 'public')) }

        it "should succeed" do
          VCR.use_cassette 'model/subscription/google_insert_member/valid' do
            expect(subscription.send(:google_insert_member)).to be_truthy
          end
        end
      end

      context "with existing email" do
        let(:subscription) { create(:subscription, user: create(:user, :with_free_membership, email: 'duplicated@example.com'), channel: create(:channel, :with_google_group, code: 'public')) }

        it "should raise duplicate exception" do
          VCR.use_cassette 'model/subscription/google_insert_member/duplicated' do
            res = subscription.send(:google_insert_member)
            expect(res.status_code).to eq(409)
            expect(res.message).to include("duplicate")
          end
        end
      end

      context "with invalid email" do
        let(:subscription) { create(:subscription, user: create(:user, :with_free_membership, email: 'hoge@gmail.com'), channel: create(:channel, :with_google_group, code: 'public')) }

        it "should raise notFound exception" do
          VCR.use_cassette 'model/subscription/google_insert_member/invalid' do
            res = subscription.send(:google_insert_member)
            expect(res.status_code).to eq(404)
            expect(res.message).to include("notFound")
          end
        end
      end
    end
  end
end

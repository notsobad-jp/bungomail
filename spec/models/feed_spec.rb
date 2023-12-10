require 'rails_helper'

RSpec.describe Feed, type: :model do
  before do
    WebMock.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").to_return(body: "https://bit.ly/3q3sjgW")
  end

  describe "index" do
    let(:ba) { create(:distribution, :with_book) }

    it "should return correct index" do
      ba.create_feeds
      feeds = ba.feeds.order(:delivery_date)

      expect(feeds.first.index).to eq(1)
      expect(feeds.last.index).to eq(30)
    end
  end

  describe "send_at" do
    let(:ba) { build(:distribution, delivery_time: "07:00:00") }
    let(:feed) { build(:feed, delivery_date: Time.zone.today, distribution: ba) }

    it "should return datetime with scheduled hour" do
      expect(feed.send_at).to eq(Time.current.change(hour: 7))
    end
  end

  describe "schedule" do
    context "when send_at already passed" do
      let(:ba) { create(:distribution, :with_book, :with_subscription) }
      let(:feed) { build(:feed, distribution: ba, delivery_date: Time.zone.yesterday) }

      it "should return without enqueueing" do
        res = feed.schedule
        expect(res).to be_nil
        expect(feed.delayed_job_id).to be_nil
      end
    end

    context "when send_at not passed yet" do
      let(:ba) { create(:distribution, :with_book, :with_subscription, delivery_time: "10:00:00") }
      let(:feed) { create(:feed, delivery_date: Time.zone.tomorrow, distribution: ba) }

      it "should enqueue the job" do
        feed.schedule
        expect(feed.delayed_job_id).not_to be_nil
      end

      it "should has correct run_at on job" do
        feed.schedule
        expect(feed.delayed_job.run_at).to eq(Time.zone.tomorrow.to_time.change(hour: 10))
      end
    end
  end

  describe "scope: :delivered" do
    let(:ba1) { create(:distribution, :with_book, delivery_time: Time.current.ago(1.minute).strftime("%T")) }
    let(:ba2) { create(:distribution, book_id: ba1.book_id, delivery_time: Time.current.since(1.minute).strftime("%T")) }

    it "should include right records" do
      feed1 = create(:feed, distribution_id: ba1.id, delivery_date: Time.zone.yesterday)  # 日付が昨日: 対象
      feed2 = create(:feed, distribution_id: ba1.id, delivery_date: Time.zone.tomorrow) # 日付が明日: 対象外
      feed3 = create(:feed, distribution_id: ba1.id, delivery_date: Time.zone.today) # 日付が今日で時間が過ぎてる: 対象
      feed4 = create(:feed, distribution_id: ba2.id, delivery_date: Time.zone.today) # 日付が今日で時間が過ぎていない: 対象外

      expect(Feed.delivered.length).to eq(2)
      expect(Feed.delivered.to_a).to eq([feed1, feed3])
    end
  end
end

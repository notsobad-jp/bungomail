require 'rails_helper'

RSpec.describe BookAssignment, type: :model do
  describe "create_feeds" do
    let(:book_assignment) { create(:book_assignment, :with_book) }

    describe "with different count" do
      context "when it has 30 count" do
        it "should have 30 feeds" do
          book_assignment.create_feeds
          expect(book_assignment.feeds.length).to eq(30)
        end
      end

      context "when it has 10 count" do
        it "should have 10 feeds" do
          book_assignment.update(end_date: book_assignment.start_date + 9)
          book_assignment.create_feeds
          expect(book_assignment.feeds.length).to eq(10)
        end
      end
    end

    describe "with different start_date" do
      context "when it start on yesterday" do
        it "should have correct delivery_date" do
          book_assignment.update(start_date: Time.zone.yesterday, end_date: Time.zone.yesterday + 29)
          book_assignment.create_feeds
          expect(book_assignment.feeds.minimum(:delivery_date)).to eq(Time.zone.yesterday)
          expect(book_assignment.feeds.maximum(:delivery_date)).to eq(Time.zone.yesterday + 29)
        end
      end
    end
  end

  describe "delivery_period_should_not_overlap" do
    let(:book_assignment) { create(:book_assignment, :with_book) }

    context "with overlapping period" do
      # 対象期間が既存レコードに先行するとき
      context "when new period proceeds the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today, end_date: Time.zone.today.next_month)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:base]).to include("予約済みの配信と期間が重複しています")
        end
      end

      # 対象期間が既存レコードに後続するとき
      context "when new period succeeds the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today.next_month, end_date: Time.zone.today.next_month + 29)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:base]).to include("予約済みの配信と期間が重複しています")
        end
      end

      # 対象期間が既存レコードを包含するとき
      context "when new period includes the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today, end_date: Time.zone.today + 50)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:base]).to include("予約済みの配信と期間が重複しています")
        end
      end

      # 対象期間が既存レコードに包含されるとき
      context "when new period is included by the existing record" do
        it "should not be valid" do
          ba = build(:book_assignment, channel: book_assignment.channel, book: book_assignment.book, start_date: Time.zone.today.next_month.beginning_of_month + 2, end_date: Time.zone.today.next_month.beginning_of_month + 12)
          expect(ba.valid?).to be_falsy
          expect(ba.errors[:base]).to include("予約済みの配信と期間が重複しています")
        end
      end
    end

    # 期間重複してても他のチャネルならOK
    context "when other channel has overlapping record" do
      it "should be valid" do
        ba = build(:book_assignment, book: book_assignment.book, start_date: Time.zone.today)
        expect(ba.valid?).to be_truthy
      end
    end
  end

  # 配信期間がユーザーの無料トライアル開始日より前だと予約できない制約
  ## createしないと:with_bookできないけど、エラーになるときはbuildでエラーメッセージを拾う
  describe "delivery_should_start_after_trial" do
    context "when start_date = trial_start_date" do
      it "should be valid" do
        channel = build(:channel)
        channel.user.update(trial_start_date: Date.parse("2021-09-01"))
        ba = create(:book_assignment, :with_book, channel: channel, start_date: Date.parse("2021-09-01"))
        expect(ba.valid?).to be_truthy
      end
    end

    context "when start_date < trial_start_date" do
      it "should not be valid" do
        channel = build(:channel)
        channel.user.update(trial_start_date: Date.parse("2021-09-01"))
        ba = build(:book_assignment, :with_book, channel: channel, start_date: Date.parse("2021-08-01"))
        expect(ba.valid?).to be_falsy
        expect(ba.errors[:base]).to include("配信開始日は無料トライアルの開始日以降に設定してください")
      end
    end

    context "when start_date > trial_start_date" do
      it "should be valid" do
        channel = build(:channel)
        channel.user.update(trial_start_date: Date.parse("2021-09-01"))
        ba = create(:book_assignment, :with_book, channel: channel, start_date: Date.parse("2021-10-01"))
        expect(ba.valid?).to be_truthy
      end
    end

    context "when trial_start_date is blank" do
      it "should be valid" do
        channel = build(:channel)
        ba = create(:book_assignment, :with_book, channel: channel, start_date: Date.parse("2021-08-01"))
        expect(ba.valid?).to be_truthy
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Distribution, type: :model do
  describe "count" do
    let(:distribution) { build(:distribution) }

    context "when it has 30 count" do
      it "should have 30 feeds" do
        expect(distribution.count).to eq(30)
      end
    end

    context "when it has 10 count" do
      it "should have 10 feeds" do
        distribution.end_date = distribution.start_date + 9
        expect(distribution.count).to eq(10)
      end
    end
  end

  describe "create_feeds" do
    let(:distribution) { create(:distribution, :with_book) }

    describe "with different count" do
      context "when it has 30 count" do
        it "should have 30 feeds" do
          distribution.create_feeds
          expect(distribution.feeds.length).to eq(30)
        end
      end

      context "when it has 10 count" do
        it "should have 10 feeds" do
          distribution.update(end_date: distribution.start_date + 9)
          distribution.create_feeds
          expect(distribution.feeds.length).to eq(10)
        end
      end
    end

    describe "with different start_date" do
      context "when it start on yesterday" do
        it "should have correct delivery_date" do
          distribution.update(start_date: Time.zone.yesterday, end_date: Time.zone.yesterday + 29)
          distribution.create_feeds
          expect(distribution.feeds.minimum(:delivery_date)).to eq(Time.zone.yesterday)
          expect(distribution.feeds.maximum(:delivery_date)).to eq(Time.zone.yesterday + 29)
        end
      end
    end
  end

  describe "delivery_period_should_not_overlap" do
    # Free Plan
    context "when user is free_plan" do
      let(:distribution) { create(:distribution, :with_book) }

      context "with overlapping period" do
        # 対象期間が既存レコードに先行するとき
        context "when new period proceeds the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today.next_month)
            expect(ba.valid?).to be_falsy
            expect(ba.errors[:base]).to include("他の配信と期間が重複しています")
          end
        end

        # 対象期間が既存レコードに後続するとき
        context "when new period succeeds the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today.next_month, end_date: Time.zone.today.next_month + 29)
            expect(ba.valid?).to be_falsy
            expect(ba.errors[:base]).to include("他の配信と期間が重複しています")
          end
        end

        # 対象期間が既存レコードを包含するとき
        context "when new period includes the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today + 50)
            expect(ba.valid?).to be_falsy
            expect(ba.errors[:base]).to include("他の配信と期間が重複しています")
          end
        end

        # 対象期間が既存レコードに包含されるとき
        context "when new period is included by the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today.next_month.beginning_of_month + 2, end_date: Time.zone.today.next_month.beginning_of_month + 12)
            expect(ba.valid?).to be_falsy
            expect(ba.errors[:base]).to include("他の配信と期間が重複しています")
          end
        end

        # 対象期間が1日だけの場合
        context "when target period and new period are both only one day" do
          it "should not be valid" do
            ba1 = create(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today)
            ba2 = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today)
            expect(ba2.valid?).to be_falsy
            expect(ba2.errors[:base]).to include("他の配信と期間が重複しています")
          end
        end
      end
    end

    # Basic Plan
    context "when user is basic_plan" do
      let(:user) { create(:user, :basic) }
      let(:distribution) { create(:distribution, :with_book, user: user) }

      context "with overlapping period" do
        # 対象期間が既存レコードに先行するとき
        context "when new period proceeds the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today.next_month)
            expect(ba.valid?).to be_truthy
          end
        end

        # 対象期間が既存レコードに後続するとき
        context "when new period succeeds the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today.next_month, end_date: Time.zone.today.next_month + 29)
            expect(ba.valid?).to be_truthy
          end
        end

        # 対象期間が既存レコードを包含するとき
        context "when new period includes the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today + 50)
            expect(ba.valid?).to be_truthy
          end
        end

        # 対象期間が既存レコードに包含されるとき
        context "when new period is included by the existing record" do
          it "should not be valid" do
            ba = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today.next_month.beginning_of_month + 2, end_date: Time.zone.today.next_month.beginning_of_month + 12)
            expect(ba.valid?).to be_truthy
          end
        end

        # 対象期間が1日だけの場合
        context "when target period and new period are both only one day" do
          it "should not be valid" do
            ba1 = create(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today)
            ba2 = build(:distribution, user: distribution.user, book: distribution.book, start_date: Time.zone.today, end_date: Time.zone.today)
            expect(ba2.valid?).to be_truthy
          end
        end
      end
    end
  end

  # 配信期間がユーザーの無料トライアル開始日より前だと予約できない制約
  ## createしないと:with_bookできないけど、エラーになるときはbuildでエラーメッセージを拾う
  describe "delivery_should_start_after_trial" do
    context "when start_date = trial_start_date" do
      xit "should be valid" do
        user = build(:user, trial_start_date: Date.parse("2021-09-01"))
        ba = create(:distribution, :with_book, user: user, start_date: Date.parse("2021-09-01"))
        expect(ba.valid?).to be_truthy
      end
    end

    context "when start_date < trial_start_date" do
      xit "should not be valid" do
        user = build(:user, trial_start_date: Date.parse("2021-09-01"))
        ba = build(:distribution, :with_book, user: user, start_date: Date.parse("2021-08-01"))
        expect(ba.valid?).to be_falsy
        expect(ba.errors[:base]).to include("配信開始日は無料トライアルの開始日以降に設定してください")
      end
    end

    context "when start_date > trial_start_date" do
      xit "should be valid" do
        user = build(:user, trial_start_date: Date.parse("2021-09-01"))
        ba = create(:distribution, :with_book, user: user, start_date: Date.parse("2021-10-01"))
        expect(ba.valid?).to be_truthy
      end
    end

    context "when trial_start_date is blank" do
      xit "should be valid" do
        user = build(:user)
        ba = create(:distribution, :with_book, user: user, start_date: Date.parse("2021-08-01"))
        expect(ba.valid?).to be_truthy
      end
    end
  end

  # 配信先アドレス一覧
  describe "#send_to" do
    # 公式配信: 有料プランユーザー全員に配信
    context "when it's an official distribution" do
      it "should be all basic_plan users" do
        free_users = create_list(:user, 3) # NG
        scheduled_users = create_list(:user, 3, :trial_scheduled) # NG
        trialing_users = create_list(:user, 3, :trialing) # OK
        basic_users = create_list(:user, 3, :basic) # OK

        admin_user = build(:admin_user)
        ba = build(:distribution, :with_book, user: admin_user)
        expect(ba.send_to.length).to eq(6)
        expect(ba.send_to.to_set).to eq((trialing_users.pluck(:email) + basic_users.pluck(:email)).to_set)
      end
    end

    # カスタム配信: 配信者だけに配信
    context "when it's a custom distribution" do
      it "should be email subscribers" do
        basic_users = create_list(:user, 3, :basic)
        free_user = create(:user)

        owner = create(:user)
        ba = create(:distribution, :with_book, user: owner)
        owner.subscribe(ba, delivery_method: "email")
        free_user.subscribe(ba, delivery_method: "email")

        expect(ba.send_to.length).to eq(2)
        expect(ba.send_to).to eq([owner.email, free_user.email])
      end
    end
  end
end

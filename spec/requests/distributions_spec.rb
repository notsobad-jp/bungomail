require "rails_helper"

RSpec.describe "Distributions", type: :request do
  let(:user) { create(:user, :basic) }
  let(:trial_scheduled_user) { create(:user, :trial_scheduled) }
  let(:trialing_user) { create(:user, :trialing) }
  let(:admin_user) { User.find_by(email: "info@notsobad.jp") }
  let(:book) { create(:aozora_book) }
  let!(:distribution) { create(:distribution, :with_subscription, book: book) }

  describe "GET /distributions" do
    context "when not logged in" do
      it "redirects to login_page" do
        get distributions_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { login(user) }

      it "returns http success" do
        get distributions_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /distributions/:id" do
    it "returns http success" do
      get distribution_path(distribution)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /distributions" do
    context "when user has a basic plan" do
      before { login(user) }

      it "creates a new distribution and redirects to its show page" do
        expect {
          post distributions_path, params: {
            distribution: { book_id: book.id, book_type: "AozoraBook", start_date: Date.today, end_date: Date.today + 1.week, delivery_time: "10:00" },
            delivery_method: "email",
          }
        }.to change(Distribution, :count).by(1)
        follow_redirect!
        expect(response.body).to include("配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。")
      end
    end

    context "when user is in trial period" do
      before { login(trialing_user) }

      it "creates a new distribution and redirects to its show page" do
        expect {
          post distributions_path, params: {
            distribution: { book_id: book.id, book_type: "AozoraBook", start_date: Date.today, end_date: Date.today + 1.week, delivery_time: "10:00" },
            delivery_method: "email",
          }
        }.to change(Distribution, :count).by(1)
        follow_redirect!
        expect(response.body).to include("配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。")
      end
    end
  end

  describe "DELETE /distributions/:id" do
    context "when user is the owner of the distribution" do
      before { login(distribution.user) }

      it "deletes the distribution and redirect" do
        expect {
          delete distribution_path(distribution)
        }.to change(Distribution, :count).by(-1)
        expect(response).to redirect_to(distributions_path)
      end
    end
  end
end

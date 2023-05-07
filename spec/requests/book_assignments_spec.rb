require "rails_helper"

RSpec.describe "BookAssignments", type: :request do
  let!(:user) { create(:user) }

  before do
    login_user(user)
  end

  describe "GET /book_assignment" do
    let!(:book_assignment) { create(:book_assignment) }

    context "when record exists" do
      example do
        get book_assignment_path(book_assignment)
        expect(response).to be_successful
      end
    end
  end
end

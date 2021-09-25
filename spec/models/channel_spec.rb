require 'rails_helper'

RSpec.describe Channel, type: :model do
  before do
    WebMock.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").to_return(body: "https://bit.ly/3q3sjgW")
  end

  describe "nearest_assignable_date" do
    context "when no feed exists" do
      let(:channel) { create(:channel) }

      it "should return tomorrow" do
        expect(channel.nearest_assignable_date).to eq(Time.zone.tomorrow)
      end
    end

    context "when assignment last_date is not passed yet" do
      let(:channel) { create(:channel, :with_book_assignment) }

      it "should return the day after last_date" do
        expect(channel.nearest_assignable_date).to eq(channel.book_assignments.first.end_date + 1)
      end
    end
  end

  describe "recent_author_ids" do
    let(:channel) { create(:channel) }

    context "when it has book_assignments" do
      it "should return recent author ids" do
        books = create_list(:aozora_book, 10)
        books.each_with_index do |book, index|
          create(:book_assignment, channel_id: channel.id, book_id: book.id, start_date: Time.zone.today.ago(index.month), end_date: Time.zone.today.ago(index.month).since(20.days))
        end
        expect(channel.recent_author_ids).to eq([1,2,3,4,5,6])
        expect(channel.recent_author_ids(3)).to eq([1,2,3])
      end
    end

    context "when it has no book_assignment" do
      it "should return blank" do
        expect(channel.recent_author_ids).to eq([])
      end
    end
  end
end

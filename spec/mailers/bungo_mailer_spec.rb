require 'rails_helper'

describe BungoMailer do

  describe '#feed_email' do
    let(:feed) { create(:feed) }
    subject(:mail) do
      described_class.with(feed: feed).feed_email.deliver_now
      ActionMailer::Base.deliveries.last
    end

    context 'when send_mail' do
      it { expect(mail.from.first).to eq('hoge.from@test.com') }
      it { expect(mail.to.first).to eq('fuga.to@test.com') }
      it { expect(mail.subject).to eq('ほげ商事の田中太郎です') }
      it { expect(mail.body).to match(/本メールはほげ商事の田中太郎からのテストメールです。/) }
    end
  end
end

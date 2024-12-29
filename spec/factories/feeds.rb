FactoryBot.define do
  factory :feed do
    association :campaign, :with_book
    title { '走れメロス(1/30)' }
    content { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec venenatis est ac tellus porttitor blandit quis in arcu. Vivamus sagittis elit tortor, quis auctor dui dignissim quis. Suspendisse lacinia nibh non magna rutrum, eu blandit ex euismod. Donec porttitor cursus lorem. Fusce efficitur metus at massa dapibus posuere eleifend in magna. Nullam nec dui dignissim, egestas dui ac, dignissim ligula. Fusce pretium, eros at lacinia malesuada, justo enim varius purus, gravida dignissim odio odio ac risus. Mauris id tortor orci. Sed commodo leo ipsum. In accumsan enim id felis accumsan laoreet. Proin sit amet ex lorem. Etiam eu turpis enim.' }
    delivery_date { Time.zone.today }
  end
end

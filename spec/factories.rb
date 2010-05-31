Factory.define :user do |user|
  user.sequence(:mailbox) { |n| n }
  user.password  '1234'
end

Factory.define :voicemail do |vm|
end

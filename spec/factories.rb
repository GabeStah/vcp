FactoryGirl.define do
  FactoryGirl.define do
    factory :race do
      name "Tauren"
    end
    factory :user do
      sequence(:name)  { |n| "Person #{n}" }
      sequence(:email) { |n| "person_#{n}@example.com"}
      password "foobar"
      password_confirmation "foobar"

      factory :admin do
        admin true
      end
    end
  end
end
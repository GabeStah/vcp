FactoryGirl.define do
  FactoryGirl.define do
    factory :character_class do
      sequence(:name)  { |n| "Class #{n}" }
    end
    factory :race do
      sequence(:name)  { |n| "Race #{n}" }
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
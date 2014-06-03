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

    factory :character do
      achievement_points 1500
      character_class
      gender 0
      level 90
      portrait "internal-record-3661/66/115044674-avatar.jpg"
      name "Kulldar"
      race
      rank 1
      realm "Hyjal"
    end
  end
end
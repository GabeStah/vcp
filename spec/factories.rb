FactoryGirl.define do
  FactoryGirl.define do
    factory :character_class do
      sequence(:blizzard_id)
      sequence(:name) { |n| "Class #{n}" }
    end
    factory :race do
      sequence(:blizzard_id)
      sequence(:name) { |n| "Race #{n}" }
      side "horde"
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
      locale "us"
      portrait "internal-record-3661/66/115044674-avatar.jpg"
      name { Faker::Name.first_name } # Brackets required to force Faker to create unique entries
      race
      rank 9
      realm { Faker::Name.last_name } # Brackets required to force Faker to create unique entries
    end
  end
end
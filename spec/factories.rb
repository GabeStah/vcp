FactoryGirl.define do
  factory :character do
    achievement_points 1500
    character_class
    gender 0
    level 90
    name { Faker::Name.first_name } # Brackets required to force Faker to create unique entries
    race
    rank 9
    region 'us'
    realm { Faker::Name.last_name } # Brackets required to force Faker to create unique entries
    verified true
  end

  factory :character_class do
    sequence(:blizzard_id)
    sequence(:name) { |n| "Class #{n}" }
  end

  factory :guild do
    achievement_points 2500
    battlegroup 'Vengeance'
    level 20
    sequence(:name) { |n| "Name #{n}" }
    region 'us'
    realm 'Hyjal'
    side 0
  end

  factory :participation do
    character
    in_raid true
    online true
    raid
    timestamp Time.zone.now
  end

  factory :race do
    sequence(:blizzard_id)
    sequence(:name) { |n| "Race #{n}" }
    side 'horde'
  end

  factory :raid do
    ended_at 4.hours.from_now
    started_at Time.zone.now
    zone
  end

  factory :standing do
    active true
    character
    points 0
  end

  factory :standing_event do
    change -0.1
    raid
    standing
    type :delinquent
  end

  factory :admin_role, class: Role do
    name :admin
  end

  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:battle_tag)  { |n| "BattleTag##{n}" }
    password 'foobar'
    password_confirmation 'foobar'

    # user_with_posts will create post data after the user has been created
    factory :admin do
      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |user|
        user.roles << create(:admin_role)
      end
    end

    # factory :admin do
    #   admin true
    # end
  end

  factory :zone do
    blizzard_id 1
    level       90
    name        'Naxxramas'
    zone_type   'raid'
  end
end
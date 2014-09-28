FactoryGirl.define do
  factory :character do
    achievement_points 1500
    character_class
    gender 0
    level 90
    portrait 'internal-record-3661/66/115044674-avatar.jpg'
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

  factory :setting do
    raid_start_time '6:30 PM'
    raid_end_time '10:30 PM'
    tardiness_cutoff_time 60
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

  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password 'foobar'
    password_confirmation 'foobar'

    factory :admin do
      admin true
    end
  end

  factory :zone do
    blizzard_id 1
    level       90
    name        'Naxxramas'
    zone_type   'raid'
  end
end
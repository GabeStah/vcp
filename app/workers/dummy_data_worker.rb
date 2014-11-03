class DummyDataWorker
  include Sidekiq::Worker
  include Errors

  def perform(raid_count)

    raid_count = raid_count || 20

    standings = Standing.where(active: true)
    zones = Zone.where(zone_type: 'raid')

    types = {
      attend: 77,
      absent: 3,
      delinquent_attendance: 5,
      delinquent_sit: 5,
      sit: 13,
    }

    if standings && zones

      type_randomizer = WeightedRandomizer.new(types)

      raid_count.times do |i|
        raid_start_time = (Time.zone.now - i.days - 30.days + rand(0..48).hours - rand(0..240).minutes)
        raid_end_time = (raid_start_time + rand(120..240).minutes)
        raid = Raid.create(
          ended_at: raid_end_time,
          started_at: raid_start_time,
          zone: zones.sample
        )

        if raid
          standings = standings.shuffle
          # Participations
          standings.each do |standing|
            type = type_randomizer.sample

            case type
              when :attend
                raid.participations.create(
                  character: standing.character,
                  in_raid: true,
                  online: true,
                  timestamp: raid_start_time
                )
              when :absent
                raid.participations.create(
                  character: standing.character,
                  in_raid: false,
                  online: false,
                  timestamp: raid_start_time
                )
              when :delinquent_attendance
                raid.participations.create(
                  character: standing.character,
                  in_raid: false,
                  online: false,
                  timestamp: raid_start_time
                )
                raid.participations.create(
                  character: standing.character,
                  in_raid: true,
                  online: true,
                  timestamp: (raid_start_time + rand(0..60).minutes)
                )
              when :delinquent_sit
                raid.participations.create(
                  character: standing.character,
                  in_raid: false,
                  online: false,
                  timestamp: raid_start_time
                )
                raid.participations.create(
                  character: standing.character,
                  in_raid: false,
                  online: true,
                  timestamp: (raid_start_time + rand(0..60).minutes)
                )
              when :sit
                raid.participations.create(
                  character: standing.character,
                  in_raid: false,
                  online: true,
                  timestamp: raid_start_time
                )
            end
          end
          # Process
          raid.process_standing_events
        end
      end
    else
      raise StandardError.new('Unable to create dummy data.')
    end
  end
end
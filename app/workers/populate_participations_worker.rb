class PopulateParticipationsWorker
  include Sidekiq::Worker
  include Errors

  sidekiq_options unique: true

  def perform
    # Get raid
    raid = Raid.last
    if raid.nil?
      raise StandardError.new('Unable to create Participation record, Raid not found.')
    end
    # Get the standings characters
    standings = Standing.all
    if standings.nil? || standings.blank?
      raise StandardError.new('Unable to create Participation record, no Standings found.')
    end
    standings.each do |standing|
      # Create 1 - 5 random entries
      entry_count = rand(1..5)
      # Split start/end times into random sized chunks based on entry_count
      random_dates = Array.new
      entry_count.times do
        random_dates << rand(raid.started_at..raid.ended_at)
      end
      random_dates = random_dates.sort

      random_dates.each do |date|
        # Random online and in_raid
        online = [true, false].sample
        in_raid = [true, false].sample
        raid.participations.create(
          character: standing.character,
          in_raid: in_raid,
          online: online,
          timestamp: date
        )
      end
    end
    raid.process_standing_events
  end
end
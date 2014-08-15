class PopulateStandingsWorker
  include Sidekiq::Worker
  include Errors

  def perform
    # Get random characters with data
    character_limit = 10
    characters = Character.where(verified: true).limit(character_limit)
    if characters.size == character_limit
      seed = 1
      characters.each do |character|
        Standing.create!(active: true,
                         character: character,
                         points: Standing.calculate_starting_points(seed: seed, players: characters.size, increment: 0.2))
        seed += 1
      end
    else
      raise StandardError.new('Verified character set not found.')
    end
  end
end
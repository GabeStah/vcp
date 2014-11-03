class PopulateStandingsWorker
  include Sidekiq::Worker
  include Errors

  sidekiq_options unique: true

  def perform(character_limit = 23)
    # Get random characters with data
    characters = Character.where(verified: true).limit(character_limit)
    if characters.size == character_limit
      seed = 1
      characters.shuffle.each do |character|
        Standing.create!(active: true,
                         character: character,
                         points: Standing.calculate_starting_points(seed: seed, players: characters.size, increment: 10))
        seed += 1
      end
    else
      raise StandardError.new('Verified character set not found.')
    end
  end
end
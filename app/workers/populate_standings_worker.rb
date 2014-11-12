class PopulateStandingsWorker
  include Sidekiq::Worker
  include Errors

  sidekiq_options unique: true

  def perform(character_limit = 23)
    # Get random characters with data
    characters = Character.where(verified: true).limit(character_limit)

    character_list = [
      'Kulldar',
      'Takaoni',
      'Dougallkin',
      'Tree',
      'Deaf',
      'Gartzarnn',
      'Shaylana',
      'Klik',
      'Citruss',
      'Aelloon',
      'Airroh',
      'Boggyb',
      'Idtrâpdât',
      'Noblood',
      'Talanvor',
      'Nesaru',
      'Dyeus',
      'Tayloreds',
      'Blynks',
      'Vikwin',
      'Nephani',
      'Zuldain',
    ]

    seed = 1
    character_list.each do |name|
      character = Character.find_by(name: name, realm: 'Hyjal', region: 'us')
      Standing.create!(active: true,
                       character: character,
                       points: Standing.calculate_starting_points(seed: seed, players: character_list.size, increment: 10)) if character
      seed += 1
    end

    # Set initial dates
    StandingEvent.where(type: :initial).each {|e| e.update(created_at: e.standing.character.created_at)}

    # if characters.size == character_limit
    #   seed = 1
    #   characters.shuffle.each do |character|
    #     Standing.create!(active: true,
    #                      character: character,
    #                      points: Standing.calculate_starting_points(seed: seed, players: characters.size, increment: 10))
    #     seed += 1
    #   end
    #
    #   # Set initial dates
    #   StandingEvent.where(type: :initial).each {|e| e.update(created_at: e.standing.character.created_at)}
    # else
    #   raise StandardError.new('Verified character set not found.')
    # end
  end
end
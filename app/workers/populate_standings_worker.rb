class PopulateStandingsWorker
  include Sidekiq::Worker
  include Errors

  def perform
    # Get 3 random characters with data
    characters = Character.where(verified: true).limit(5)
    if characters.size == 5
      characters.each do |character|
        standing = Standing.new(character: character)
        standing.save
      end
    else
      raise StandardError.new('Verified character set not found.')
    end
  end
end
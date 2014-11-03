class PopulateCharactersWorker
  include Sidekiq::Worker
  include Errors

  sidekiq_options unique: true

  def perform
    [
      'Boggyb',
      'Dougallxin',
      'Airroh',
      'Klik',
      'Tree',
      'Aelloon',
      'Talanvor',
      'Citruss',
      'Nesaru',
      'Takaoni',
      'Nephani',
      'Tayloreds',
      'Kogeth',
      'Kulldar',
      'Blinks',
      'Shaylana',
      'Idtrâpdât',
      'Noblood',
      'Gartzarnn',
      'Deaf',
      'Vikwin',
      'Dyeus',
    ].each do |character|
      Character.create(created_at: (Time.zone.now - 15.days + rand(0..48).hours - rand(0..240).minutes), name: character, realm: 'Hyjal', region: 'us')
    end
  end
end
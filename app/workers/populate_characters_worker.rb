class PopulateCharactersWorker
  include Sidekiq::Worker
  include Errors

  sidekiq_options unique: true

  def perform(args={})
    days_old = args[:days_old] || 120
    [
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
    ].each do |character|
      Character.create(created_at: (Time.zone.now - days_old.days + rand(0..48).hours - rand(0..240).minutes), name: character, realm: 'Hyjal', region: 'us')
    end
  end
end
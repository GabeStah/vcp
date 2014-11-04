class PopulateCharactersWorker
  include Sidekiq::Worker
  include Errors

  sidekiq_options unique: true

  def perform(args={})
    days_old = args[:days_old] || 120
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
      'Kulldos',
      'Kullded',
      'Xiae',
      'Blinks',
      'Shaylana',
      'Idtrâpdât',
      'Noblood',
      'Gartzarnn',
      'Deaf',
      'Vikwin',
      'Dyeus',
    ].each do |character|
      Character.create(created_at: (Time.zone.now - days_old.days + rand(0..48).hours - rand(0..240).minutes), name: character, realm: 'Hyjal', region: 'us')
    end
  end
end
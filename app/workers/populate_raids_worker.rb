class PopulateRaidsWorker
  include Sidekiq::Worker
  include Errors

  sidekiq_options unique: true

  def perform
    # Create a few basic raids
    unless Zone.last.nil?
      Raid.create(
        ended_at: TimeManagement.raid_end,
        started_at: TimeManagement.raid_start,
        zone: Zone.last
      )
    else
      raise StandardError.new('Unable to create Raid.')
    end
  end
end
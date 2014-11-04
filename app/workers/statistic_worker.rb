class StatisticWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options unique: true

  recurrence do
    hourly.minute_of_hour(2,4,5,6,8,
                          10,12,14,16,18,
                          20,22,24,26,28,
                          30,32,34,36,38,
                          40,42,44,46,48,
                          50,52,54,56,58,
                          60)
  end

  def perform
    # Find all active standings
    Standing.where(active: true).each do |standing|
      standing.update_statistics
    end
  end
end
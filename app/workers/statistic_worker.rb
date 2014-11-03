class StatisticWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options unique: true

  recurrence do
    secondly(60)
    #daily(1).hour_of_day(2)
  end

  def perform
    # Find all active standings
    Standing.where(active: true).each do |standing|
      standing.update_statistics
    end
  end
end
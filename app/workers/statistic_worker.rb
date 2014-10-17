class StatisticWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    secondly(120)
    #daily(1).hour_of_day(2)
  end

  def perform
    # Find all active standings
    Standing.where(active: true).each do |standing|
      standing.update_statistics
    end
  end
end
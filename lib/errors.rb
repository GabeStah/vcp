module Errors
  class BattleNetError < StandardError
    def initialize(args = {})
      @message = args[:message]
      @type = args[:type] || 'nok'
    end

    def message
      if @message == "When in doubt, blow it up. (page not found)"
        @message = "Battle.net returned an unknown error."
      end
      @message
    end
  end
end
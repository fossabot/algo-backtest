module AlgoBacktester
  module Event
    abstract struct AbstractEvent
      property timestamp : Time
      property symbol : String

      def initialize(@timestamp : Time, @symbol : String)
      end
    end
  end
end

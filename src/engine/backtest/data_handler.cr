module AlgoBacktester
  class DataHandler
    property stream : Array(Bar)
    property history : Array(Bar)

    def initialize(@latest = Hash(String, Bar).new,
                   @list = Hash(String, Array(Bar)).new,
                   @stream = [] of Bar,
                   @history = [] of Bar)
    end

    def next! : Bar
      if @stream.empty?
        raise EmptyDataHandlerError.new("Next called on an empty stream")
      end

      dh = @stream.shift
      @history << dh

      # update list of current data events
      update_latest(dh)

      # update list of data events for single symbol
      update_list(dh)

      return dh
    end

    def empty?
      return stream.empty?
    end

    def latest(symbol : String) : Bar?
      return @latest[symbol]?
    end

    def list(symbol : String) : Array(Bar)?
      return @list[symbol]?
    end

    def reset!
      @latest = Hash(String, Bar).new
      @list = Hash(String, Array(Bar)).new
      @stream = history
      @history = [] of Bar
    end

    def sort_stream!
      @stream.sort! do |b1, b2|
        if b1.timestamp == b2.timestamp
          return b1.symbol < b2.symbol
        end

        return b1.timestamp <=> b2.timestamp
      end
    end

    def update_latest(event : Bar)
      @latest[event.symbol] = event
    end

    def update_list(event : Bar)
      unless @list.has_key?(event.symbol)
        @list[event.symbol] = [] of Bar
      end

      @list[event.symbol] << event
    end
  end
end

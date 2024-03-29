require "../../spec_helper"

describe AlgoBacktester::DataHandler do
  describe "#reset" do
    it "should reset with empty data stream" do
      dh = AlgoBacktester::DataHandler.new
      dh.stream = [create_bar] of AlgoBacktester::Event::Bar
      dh.history = [create_bar] of AlgoBacktester::Event::Bar
      dh.update_latest(create_bar)
      dh.reset!
      dh.stream.empty?.should be_false
      dh.latest("AAPL").should be_nil
      dh.list("AAPL").should be_nil
      dh.history.empty?.should be_true
    end

    it "should reset with empty data" do
      dh = AlgoBacktester::DataHandler.new
      dh.reset!
      dh.stream.empty?.should be_true
      dh.latest("AAPL").should be_nil
      dh.list("AAPL").should be_nil
      dh.history.empty?.should be_true
    end
  end

  describe "#next" do
    it "should add a single event to history" do
      dh = AlgoBacktester::DataHandler.new
      dh.stream = [create_bar, create_bar, create_bar] of AlgoBacktester::Event::Bar
      dh.history = [] of AlgoBacktester::Event::Bar
      dh.update_latest(create_bar)
      dh.update_list(create_bar)

      dh.stream.empty?.should be_false
      dh.history.empty?.should be_true

      dh.next!.should_not be_nil

      dh.history.size.should eq(1)
    end

    it "should add the multiple events to history" do
      dh = AlgoBacktester::DataHandler.new

      dh.stream = [
        create_bar({close: 100.0_f64}),
        create_bar({close: 200.0_f64}),
      ] of AlgoBacktester::Event::Bar

      dh.history = [] of AlgoBacktester::Event::Bar
      dh.update_latest(create_bar)
      dh.update_list(create_bar)

      dh.stream.empty?.should be_false
      dh.history.empty?.should be_true

      dh.next!.price.should eq(100.0_f64)
      dh.next!.price.should eq(200.0_f64)

      dh.history.size.should eq(2)
    end

    it "should fail when no events are provided" do
      dh = AlgoBacktester::DataHandler.new
      expect_raises(Exception) do
        dh.next!
      end
      dh.history.empty?.should be_true
    end
  end

  describe "#update_latest" do
    it "should update empty latest" do
      dh = AlgoBacktester::DataHandler.new
      dh.latest("AAPL").should be_nil
      dh.update_latest(create_bar)
      dh.latest("AAPL").should_not be_nil
    end

    it "should update filled latest" do
      dh = AlgoBacktester::DataHandler.new
      dh.stream = [create_bar, create_bar, create_bar] of AlgoBacktester::Event::Bar

      old_date = 3.days.ago
      new_date = Time.local

      old_bar = create_bar()
      old_bar.timestamp = old_date

      new_bar = create_bar()
      new_bar.timestamp = new_date

      dh.update_latest(old_bar)
      dh.latest("AAPL").try { |t| t.timestamp.should eq(old_date) }

      # Should replace old bar with new bar
      dh.update_latest(new_bar)
      dh.latest("AAPL").try { |t| t.timestamp.should eq(new_date) }
    end
  end

  describe "#update_list" do
    it "should update empty list" do
      dh = AlgoBacktester::DataHandler.new
      dh.list("AAPL").should be_nil
      dh.update_list(create_bar)
      dh.list("AAPL").should_not be_nil
    end

    it "should update filled list" do
      dh = AlgoBacktester::DataHandler.new
      dh.stream = [create_bar, create_bar, create_bar] of AlgoBacktester::Event::Bar

      old_date = 3.days.ago
      new_date = Time.local

      old_bar = create_bar()
      old_bar.timestamp = old_date

      new_bar = create_bar()
      new_bar.timestamp = new_date

      dh.update_list(old_bar)
      dh.list("AAPL").try { |tArr| tArr.last.timestamp.should eq(old_date) }

      # Should replace old bar with new bar
      dh.update_list(new_bar)
      dh.list("AAPL").try { |tArr| tArr.last.timestamp.should eq(new_date) }
    end
  end
end

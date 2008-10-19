require File.dirname(__FILE__) + '/spec_helper'

describe DateRange do
  describe ".match?" do
    it "should return true if supplied date" do
      DateRange.match?("2006-7-12 14:30:15 - 2008").should be_true
      DateRange.match?("2006-7-12 14:30:15").should be_true
      DateRange.match?("2006-7-12 14:30").should be_true
      DateRange.match?("2006-7-12 14").should be_true
      DateRange.match?("2006-7-12").should be_true
      DateRange.match?("2006-7").should be_true
      DateRange.match?("2006").should be_true 
    end
    
    it "should return false if suplied nonsense" do
      DateRange.match?("asdas").should be_false
    end
  end
  
  describe ".parse" do
    it "should make year be equal to year-end of year" do
      time = Time.parse('2008-01-01')
      DateRange.parse("#{time.year}").should eql(
        [time, time.end_of_year])
    end
    
    it "should make year-month be equal to year-month - end of month" do
      time = Time.parse('2008-02-01')
      DateRange.parse("2008-02").should eql(
        [time, time.end_of_month])
    end
    
    it "should make year-month-day be equal to " +
    "year-month-day - end of day" do
      time = Time.parse('2008-02-12')
      DateRange.parse("2008-02-12").should eql(
        [time, time.end_of_day])
    end
    
    it "should make year-month-day hour be equal to " +
    "year-month-day hour - end of hour" do
      time = Time.parse('2008-02-12 20:00:00')
      end_time = Time.parse('2008-02-12 20:59:59')
      DateRange.parse("2008-02-12 20").should eql(
        [time, end_time])
    end
    
    it "should make year-month-day hour:minute be equal to " +
    "year-month-day hour:minute - end of minute" do
      time = Time.parse('2008-02-12 20:12:00')
      end_time = Time.parse('2008-02-12 20:12:59')
      DateRange.parse("2008-02-12 20:12").should eql(
        [time, end_time])
    end
    
    # Bugfix
    it "should not fail on 2008-09-19" do
      lambda do
        DateRange.parse("2008-09-19")
      end.should_not raise_error
    end
    
    it "should return [Time, nil] on single exact date" do
      from, to = DateRange.parse("2004-05-06 20:20:20")
      from.should be_instance_of(Time)
      to.should be_nil
    end
    
    it "should return 2 Time objects on correct range" do
      from, to = DateRange.parse("2004-05-06 2004-10-10")
      from.should be_instance_of(Time)
      to.should be_instance_of(Time)
    end
    
    it "should return [nil, Time] if from is broken" do
      from, to = DateRange.parse("2004-13-06 2004-10-10")
      from.should be_nil
      to.should be_instance_of(Time)
    end
    
    it "should return [Time, nil] if end is broken" do
      from, to = DateRange.parse("2004-05-06 2004-13-10")
      from.should be_instance_of(Time)
      to.should be_nil
    end
    
    it "should return [nil, nil] if everything is fucked up" do
      from, to = DateRange.parse("2004-13-06 2004-14-10")
      from.should be_nil
      to.should be_nil
    end
  end
end

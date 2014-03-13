require File.expand_path('../helper', __FILE__)

describe "business hours" do
  describe "with a standard Time object" do

    it "should add minutes part of hours count to business hours" do
      BusinessTime::Config.beginning_of_workday = "8:30 am"
      BusinessTime::Config.end_of_workday = "5:00 pm"
      starttime = Time.parse("14 March 2014 9:00am")
      endtime   = Time.parse("17 March 2014 9:00am")
      expected = 8.5.business_hours.after(starttime)
      assert_equal endtime, expected
    end

    it "move to tomorrow if we add 8 business hours" do
      first = Time.parse("Aug 4 2010, 9:35 am")
      later = 8.business_hours.after(first)
      expected = Time.parse("Aug 5 2010, 9:35 am")
      assert_equal expected, later
    end

    it "move to yesterday if we subtract 8 business hours" do
      first = Time.parse("Aug 4 2010, 9:35 am")
      later = 8.business_hours.before(first)
      expected = Time.parse("Aug 3 2010, 9:35 am")
      assert_equal expected, later
    end

    it "take into account a weekend when adding an hour" do
      friday_afternoon = Time.parse("April 9th 2010, 4:50 pm")
      monday_morning = 1.business_hour.after(friday_afternoon)
      expected = Time.parse("April 12th 2010, 9:50 am")
      assert_equal expected, monday_morning
    end

    it "take into account a weekend when adding an hour, using the common interface #since" do
      friday_afternoon = Time.parse("April 9th 2010, 4:50 pm")
      monday_morning = 1.business_hour.since(friday_afternoon)
      expected = Time.parse("April 12th 2010, 9:50 am")
      assert_equal expected, monday_morning
    end

    it "take into account a weekend when subtracting an hour" do
      monday_morning = Time.parse("April 12th 2010, 9:50 am")
      friday_afternoon = 1.business_hour.before(monday_morning)
      expected = Time.parse("April 9th 2010, 4:50 pm")
      assert_equal expected, friday_afternoon
    end

    it "take into account a holiday" do
      BusinessTime::Config.holidays << Date.parse("July 5th, 2010")
      friday_afternoon = Time.parse("July 2nd 2010, 4:50pm")
      tuesday_morning = 1.business_hour.after(friday_afternoon)
      expected = Time.parse("July 6th 2010, 9:50 am")
      assert_equal expected, tuesday_morning
    end

    it "add hours in the middle of the workday"  do
      monday_morning = Time.parse("April 12th 2010, 9:50 am")
      later = 3.business_hours.after(monday_morning)
      expected = Time.parse("April 12th 2010, 12:50 pm")
      assert_equal expected, later
    end

    it "roll forward to 9 am if asked in the early morning" do
      crack_of_dawn_monday = Time.parse("Mon Apr 26, 04:30:00, 2010")
      monday_morning = Time.parse("Mon Apr 26, 09:00:00, 2010")
      assert_equal monday_morning, Time.roll_forward(crack_of_dawn_monday)
    end

    it "roll forward to the next morning if aftern business hours" do
      monday_evening = Time.parse("Mon Apr 26, 18:00:00, 2010")
      tuesday_morning = Time.parse("Tue Apr 27, 09:00:00, 2010")
      assert_equal tuesday_morning, Time.roll_forward(monday_evening)
    end

    it "consider any time on a weekend as equivalent to monday morning" do
      sunday = Time.parse("Sun Apr 25 12:06:56, 2010")
      monday = Time.parse("Mon Apr 26, 09:00:00, 2010")
      assert_equal 1.business_hour.before(monday), 1.business_hour.before(sunday)
    end

    it "respect work_hours" do
      friday = Time.parse("December 24, 2010 15:00")
      monday = Time.parse("December 27, 2010 11:00")
      BusinessTime::Config.work_hours = {
        :mon=>["9:00","17:00"],
        :fri=>["9:00","17:00"],
        :sat=>["10:00","15:00"]
      }
      assert_equal monday, 9.business_hours.after(friday)
    end

    it "respect work_hours when starting before beginning of workday" do
      friday = Time.parse("December 24, 2010 08:00")
      monday = Time.parse("December 27, 2010 11:00")
      BusinessTime::Config.work_hours = {
        :mon=>["9:00","17:00"],
        :fri=>["9:00","17:00"],
        :sat=>["10:00","15:00"]
      }
      assert_equal monday, 15.business_hours.after(friday)
    end

    it "respect work_hours with some 24 hour days" do
      friday = Time.parse("December 24, 2010 15:00")
      monday = Time.parse("December 27, 2010 11:00")
      BusinessTime::Config.work_hours = {
        :mon=>["0:00","0:00"],
        :fri=>["0:00","0:00"],
        :sat=>["11:00","15:00"]
      }
      assert_equal monday, 24.business_hours.after(friday)
    end

    it "respect work_hours with some 24 hour days when starting before beginning of workday" do
      saturday = Time.parse("December 25, 2010 08:00")
      monday = Time.parse("December 27, 2010 11:00")
      BusinessTime::Config.work_hours = {
        :mon=>["0:00","0:00"],
        :fri=>["0:00","0:00"],
        :sat=>["11:00","15:00"]
      }
      assert_equal monday, 15.business_hours.after(saturday)
    end
  end
end

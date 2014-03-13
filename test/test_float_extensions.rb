require File.expand_path('../helper', __FILE__)

describe "float extensions" do
  it "respond to business_hours by returning an instance of BusinessHours" do
    assert(1.5.respond_to?(:business_hour))
    assert(1.5.respond_to?(:business_hours))
    assert 1.5.business_hour.instance_of?(BusinessTime::BusinessHours)
  end

  it "respond to business_days by returning an instance of BusinessDays" do
    assert(1.5.respond_to?(:business_day))
    assert(1.5.respond_to?(:business_days))
    assert 1.5.business_day.instance_of?(BusinessTime::BusinessDays)
  end
end

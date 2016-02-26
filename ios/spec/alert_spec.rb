require 'spec_helper'

describe "Validate Alert Popups #{ENV["UDID"]}" do

  it 'Alert popup text', :sauce do
    find_element(:id, "show alert").click
    expect(texts.first.text).to eq "Cool title"
    expect(texts.last.text).to eq "FAIL ON PURPOSE!!!"
  end
end
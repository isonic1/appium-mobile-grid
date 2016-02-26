require 'spec_helper'

describe "Validate Test App Features #{ENV["UDID"]}" do
  
  it 'Compute Sum' do
    a = rand(99); b = rand(99)
    find_element(:id, "IntegerA").type a
    find_element(:id, "IntegerB").type b
    find_element(:id, "ComputeSumButton").click
    expect(find_element(:id, "Answer").text).to eq (a + b).to_s
  end
  
  it 'Slide Slidder' do
    slider = find_element(:class, "UIASlider")
    Appium::TouchAction.new.press(element: slider, x: 60, y: 3).move_to(element: slider, x: 150, y: 3).release.perform
    expect(slider.value).to eq "100%"
  end
end
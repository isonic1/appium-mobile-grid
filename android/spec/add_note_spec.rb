require 'spec_helper'

describe "Add Note Scenarios #{ENV["UDID"]}" do
  
  before :each do
    wait_true { find_element(:id, 'android:id/action_bar_title').text.eql? "Notes" }
    find_element(:id, 'com.example.android.notepad:id/menu_add').click
    wait_true { find_element(:id, "android:id/action_bar_title").text.eql? "New note" }
  end
  
  it 'Create A Note', :sauce do
    note = Lorem.sentence
    find_element(:id, 'com.example.android.notepad:id/note').send_keys note
    find_element(:id, 'com.example.android.notepad:id/menu_save').click
    wait_true { find_element(:id, "android:id/action_bar_title").text.eql? "Notes" }
    expect(find_element(:id, 'android:id/text1').text).to eq "FAIL ON PURPOSE!!!"
  end
end
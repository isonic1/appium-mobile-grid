require 'spec_helper'

describe "Modify Note Scenarios #{ENV["UDID"]}" do
  
  before :each do
    wait_true { find_element(:id, 'android:id/action_bar_title').text == "Notes" }
    find_element(:id, 'com.example.android.notepad:id/menu_add').click
    wait_true { find_element(:id, "android:id/action_bar_title").text == "New note" }
    @note = Lorem.sentence
    find_element(:id, 'com.example.android.notepad:id/note').send_keys @note
    sleep 5
    find_element(:id, 'com.example.android.notepad:id/menu_save').click
    wait_true { find_element(:id, "android:id/action_bar_title").text == "Notes" }
  end
    
  it 'Delete A Note', sauce: false do
    find_elements(:id, 'android:id/text1').find { |note| note.text.eql? @note }.click
    if exists { find_element(:id, "com.example.android.notepad:id/menu_delete") }
      find_element(:id, "com.example.android.notepad:id/menu_delete").click
    else
      find_element(:id, 'More options').click
      find_element(:name, 'Delete').click
    end
    wait_true { find_element(:id, "android:id/action_bar_title").text.eql? "Notes" }
    if exists { find_element(:id, 'android:id/text1') }
      notes = find_elements(:id, 'android:id/text1').map { |note| note.text }
    else
      notes = []
    end
    expect(notes).to_not include @note
  end
end
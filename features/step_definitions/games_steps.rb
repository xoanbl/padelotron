
Given /^an existing and confirmed friendly game between "([^"]*)" and "([^"]*)" for today$/ do |team1_name, team2_name|
  game = Game.create_friendly(Team.find_by_name(team1_name),
                       Team.find_by_name(team2_name),
                       Date.today + 12.hours)
  game.confirm!
  #skip the sent email, it's already confirmed so we are not testing that
  ActionMailer::Base.deliveries.clear
end

When /^I select "([^"]*)" as first team$/ do |first_team_name|
  select first_team_name, :from => "game_team1_id"
end

When /^I select "([^"]*)" as second team$/ do |second_team_name|
  select second_team_name, :from => "game_team2_id"
end

When /^I select '(\d+)'\/"([^"]*)"\/'(\d+)', '(\d+)':'(\d+)' as play date$/ do |day, month, year, hours, minutes|
  select day, :from => 'game_play_date_3i'
  select month, :from => 'game_play_date_2i'
  select year, :from => 'game_play_date_1i'
  select hours, :from => 'game_play_date_4i'
  select minutes, :from => 'game_play_date_5i'
end

Then /^"([^"]*)" should receive a friendly game offer from "([^"]*)" for '(\d+)'\/'(\d+)'\/'(\d+)', '(\d+)':'(\d+)'$/ do |player_email, rival_team_name, day, month, year, hours, minutes|
  email = ActionMailer::Base.deliveries.last
  email.should_not be_blank
  email.to.should be_include(player_email)
  email.subject.should == "Friendly game offer from #{rival_team_name} received" 
  email.body.should be_include("You received an offer to play a padel game against #{rival_team_name} at #{day}/#{month}/#{year}, #{hours}:#{minutes}")
end

Given /^a friendly game "([^"]*)" creation process between "([^"]*)" and "([^"]*)" for today initiated by "([^"]*)"$/ do |game_description, team1_name, team2_name, initiating_team_name|
  game = Game.create(:team1 => Team.find_by_name(team1_name),
                     :team2 => Team.find_by_name(team2_name),
                     :play_date =>  Date.today + 12.hours)
end

When /^"([^"]*)" clicks in the "([^"]*)" button of the received friendly confirmation email$/ do |player_email, button|
  email = ActionMailer::Base.deliveries.first
  email.should_not be_blank
  confirm_url,reject_url = email.body.to_s.scan /\/confirmations\/\d*/
  next_url = button == 'Confirm' ? confirm_url : reject_url
  ActionMailer::Base.deliveries.delete(email)
  visit next_url
end

Then /^"([^"]*)" and "([^"]*)" should receive a friendly game against "([^"]*)" confirmation email$/ do |player1_email, player2_email, rival_team_name|
  email = ActionMailer::Base.deliveries.select {|email| email.to.include?(player1_email) and email.to.include?(player2_email)}.first
  email.should_not be_blank
  email.subject.should == "Friendly game against #{rival_team_name} confirmed"
  email.body.should be_include("You confirmed a friendly game against #{rival_team_name}")
end

Then /^"([^"]*)" and "([^"]*)" should receive a friendly game against "([^"]*)" cancellation email$/ do |player1_email, player2_email, rival_team_name|
  email = ActionMailer::Base.deliveries.select {|email| email.to.include?(player1_email) and email.to.include?(player2_email)}.first
  email.should_not be_blank
  email.subject.should == "Friendly game against #{rival_team_name} cancelled"
  email.body.should be_include("You cancelled a friendly game against #{rival_team_name}")
end

Given /^an existing and confirmed game "([^"]*)" between "([^"]*)" and "([^"]*)" for today$/ do |game_desc, team1_name, team2_name|
  game = Game.create(:description => game_desc,
                     :team1 => Team.find_by_name(team1_name),
                     :team2 => Team.find_by_name(team1_name),
                     :play_date => Date.today.beginning_of_day)
  game.confirm!
end

Then /^I should see '(\d+)' games listed$/ do |game_count|
  page.should have_selector("div.game_panel", :count => game_count.to_i)
end

Then /^I should see the game "([^"]*)" between "([^"]*)" and "([^"]*)" for today at "([^"]*)":"([^"]*)"$/ do |game_desc, team1_name, team2_name, hours, minutes|
  page.should have_selector("div.game_panel h4.description", :content => game_desc) do |game_elem|
    game_elem.should have_selector("h4.team1", :content => team1_name)
    game_elem.should have_selector("h4.team2", :content => team2_name)
    game_elem.should have_selector("h4.play_date", :content => "#{hours}:#{minutes}")
  end
end

When /^I click on the game "([^"]*)" between "([^"]*)" and "([^"]*)" for today$/ do |game_desc, team1, team2|
  within "div.game_panel h4.description" do
    follow "view info"
  end
end

Then /^I should see today at "([^"]*)":"([^"]*)" as game play date$/ do |hours, minutes|
  page.should have_selector("h4.play_date", :content => "#{hours}:#{minutes}")
end


class Game < ActiveRecord::Base

  belongs_to :team1, :class_name => "Team"
  belongs_to :team2, :class_name => "Team"

  after_create :create_confirmations_if_friendly_game, :deliver_game_confirmation_ask_email
  
  has_many :confirmations, :as => :confirmable

  def teams
    [team1,team2]
  end

  def confirm!
    update_attributes :status => 'confirmed'
    #deliver_team_joined_confirmation_email
  end

  def reject!
    update_attributes :status => 'rejected'
    #deliver_team_cancellation_email
  end

  def self.create_friendly(team1,team2,play_date)
    Game.create(:team1 => team1,:team2 => team2, :play_date => play_date, :game_type => 'friendly')
  end

  def is_friendly?
    game_type == "friendly"
  end

  #messages to show in confirmations
  def confirmation_message
    "confirmed a game against #{self.team1.name}"
  end

  def rejection_message
    "reject playing a game against #{self.team1.name}"
  end
  #messages to show in confirmations
  def confirmation_ask_message
    "confirm the friendly game against #{self.team1.name}"
  end

  def rejection_ask_message
    "reject the friendly game against #{self.team1.name}"
  end

  private

  def create_confirmations_if_friendly_game
    if self.is_friendly?
      ["accept", "reject"].each do |action_name|
        self.confirmations << Confirmation.new(:action => action_name, :code => rand(100000000000).to_s)
      end
    end
  end

  def deliver_game_confirmation_ask_email
    GameConfirmationMailer.friendly_game_confirmation_email(self).deliver
  end
  
end

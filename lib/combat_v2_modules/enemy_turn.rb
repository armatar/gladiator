require_relative '../user_interface.rb'

module EnemyTurn
  include UserInterface

  def player_auto_attack
    damage = attack_with_equipped_weapon(@enemy, @player_character)
    @player_character.hp -= damage
  end
end
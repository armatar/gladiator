require_relative 'combat_modules.rb'
require_relative 'user_interface.rb'

class Combat
  include CombatModules
  include UserInterface

  def initialize(player_character, enemy, special_events)
    @player_character = player_character
    @enemy = enemy
    @special_events = special_events
    @message = ""
  end

  def start_combat
    player_turn = player_goes_first?(@player_character.init, @enemy.init)
    combat_result = turn_based_combat(player_turn)
    return combat_result
  end

  def turn_based_combat(player_turn)
    combat_phase(player_turn)
    result = check_for_death(@player_character.hp, @enemy.hp) 
    if result
      return result
    end
    player_turn ^= true

    combat_phase(player_turn)
    result = check_for_death(@player_character.hp, @enemy.hp) 
    if result
      return result
    end
    player_turn ^= true
  end

  def player_goes_first?(player_init, enemy_init)
    if player_init > enemy_init
      return true
    else
      return false
    end
  end

  def combat_phase(player_turn)
    player_turn ? player_phase : enemy_phase
  end

  def player_phase
  end

  def enemy_phase
  end

  def check_for_death(player_character_hp, enemy_hp)
    if player_character_hp <= 0
      return "player"
    elsif enemy_hp <= 0
      return "enemy"
    else
      return false
    end
  end
end
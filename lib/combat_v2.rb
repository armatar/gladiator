require_relative 'user_interface.rb'
require_relative 'status_effects.rb'
require_relative 'combat_maneuvers.rb'

class Combat
  include UserInterface

  attr_reader :player_character, :enemy, :turn, :enemy_cbm_status, :player_cbm_status

  def initialize(player_character, enemy, special_events)
    @player_character = player_character
    @enemy = enemy
    @special_events = special_events
    @message = ""
    @turn = 1
    create_counters
    @status_effects = StatusEffects.status_effects
    create_cbm_status
  end

  def create_cbm_status
    @enemy_cbm_status = false
    @player_cbm_status = false
  end

  def create_counters
    @player_buff_counter = {}
    @player_curse_counter = {}
    @enemy_buff_counter = {}
    @enemy_curse_counter = {}
  end

  def fight!
    who_dead = start_combat(player_goes_first?(@player_character.init, @enemy.init))
    display_activity_log(@message)
    if who_dead == "enemy"
      return kill_or_spare
    else
      return who_dead
    end
  end

  def start_combat(player_turn)
    combat_loop(player_turn)
    who_dead = who_is_dead
    return who_dead
  end

  #Continues combat until either player or enemy is dead
  def combat_loop(player_turn)
    loop do
      result = turn_based_combat(player_turn)
      if result
        return result
      end
      @turn += 1
    end
  end

  #Ensures that both combatants get a turn, checking to see if someone dies in between each turn
  def turn_based_combat(player_turn)
    combat_result = combat_phase(player_turn)
    if combat_result
      return combat_result
    end

    combat_result = combat_phase(!player_turn)
    return combat_result
  end


  def combat_phase(player_turn)
    initiate_correct_turn(player_turn)
    result = check_for_death
    return result
  end

  def player_goes_first?(player_init, enemy_init)
    if player_init > enemy_init
      return true
    else
      return false
    end
  end

  def initiate_correct_turn(player_turn)
    player_turn ? player_phase : enemy_phase
  end

  def player_combat_display
    system "clear"
    display_activity_log(@message)
    display_combat_options(@player_character)
    display_combat_info(@player_character, @enemy, @turn)
  end

  def player_phase
    attack = false
    while !attack
      player_combat_display
      @message = ""
      @message += Paint["Player Turn ------\n", :red, :bold]
      attack = @player_character.attack
    end
    @message += attack[:message]
    @message += @enemy.defend(attack)
  end

  def enemy_phase
    @message += Paint["Enemy Turn ------\n", :red, :bold]
    attack = false
    while !attack
      attack = @enemy.attack
    end
    @message += attack[:message]
    @message += @player_character.defend(attack)
  end

  def kill_or_spare
    continue = false
    while !continue
      print_line
      answer = ask_question("Kill him or spare his life?", ["kill", "spare"], 
                            "Think carefully about your decision as it may have lasting effects.")
      if answer == "kill" || answer == "spare"
        return answer
      else
        print_error_message("Please type either 'kill' or 'spare'.")
      end
    end
  end

  def who_is_dead
    if @player_character.hp <= 0 && @enemy.hp <= 0
      return "both"
    elsif @player_character.hp <= 0
      return "player"
    else
      return "enemy"
    end
  end

  def check_for_death
    if @player_character.hp <= 0 || @enemy.hp <= 0
      return true
    else
      return false
    end
  end
end
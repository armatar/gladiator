require 'paint'
require_relative 'interface.rb'
require_relative 'player_character.rb'
require_relative "combat_modules.rb"

class Combat

  include Interface
  include CombatModules

  def initialize(ally, enemy)
    #ally and enemy could be arrays in case of double battles
    @ally = ally
    @enemy = enemy
    create_status_effects_list
    create_list_of_maneuvers
  end

  def turn_based_combat

    continue = false
    @turn = 1
    @message = ""
    @enemy_previous_weapon = @enemy.equipped_weapon
    @ally_buff_counter = {}
    @enemy_buff_counter = {}
    @ally_curse_counter = {}
    @enemy_curse_counter = {}
    @current_enemy_cbm = false
    @grappled = false

    while !continue
      system "clear"

      display_activity_log

      if @current_enemy_cbm && @current_enemy_cbm[:name] == "grapple"
        result = enemy_is_grappled
      else
        display_combat_options(@ally)
        display_combat_info(@ally, @enemy, @turn)
        result = player_turn
      end
      if result == "kill" || result == "spare"
        clear_out_player_effects
        return result
      elsif !result
        if @current_enemy_cbm
          result = update_enemy_cbm
        else
          result = enemy_turn
        end
        if result == "dead"
          clear_out_player_effects
          return result
        end
      elsif result
      end
      @turn += 1
      restore_buff_status(@ally_buff_counter, @turn, "ally")
      restore_buff_status(@enemy_buff_counter, @turn, "enemy")
      restore_curse_status(@ally_curse_counter, @turn, "ally")
      restore_curse_status(@enemy_curse_counter, @turn, "enemy")
    end
  end

  def player_turn
      answer = ask_question("What do you want to do?", false, "You can use the number if you want!")
      system "clear"
      if answer == "swing your #{@ally.equipped_weapon[:name]}" || answer == "1"
        #auto attack
        player_auto_attack
        return check_if_dead
      elsif answer == "use a skill" || answer == "2"
        # use a skill
        @message += "You can't use that option yet..."
        @turn -= 1
        return true
      elsif answer == "cast a spell" || answer == "3"
        # cast a spell
        return player_cast_spell
      elsif answer == "perform a combat maneuver" || answer == "4"
        # do cbm
        return player_do_cbm
      elsif answer == "use an item" || answer == "5"
        # use an item
        item_used = @ally.use_item
        if item_used
          result += item_used
          if !result
           @turn -= 1
          return true
          else
            @message = result
            return false
          end
        else
          @turn -= 1
          return true
        end
      elsif answer == "equip a weapon" || answer == "6"
        # equip a weapon
        changed = @ally.equip_weapon
        if changed
          @message += changed 
          return false
        else
          @turn -= 1
          return true
        end
      else 
        @message += "Please select a number from the list provided."
        @turn -= 1
        return true
      end
  end

  def enemy_turn
    damage = attack_with_weapon(@enemy, @ally)
      if damage
        @ally.hp -= damage
      end
      
      if @ally.hp <= 0
        kill = true # may make it to where enemy can choose to spare you.
        if kill
          return "dead"
        end
      else
        return false
      end
  end

  def display_activity_log
      print_line
      print_basic_message("Activity Log")
      print_line
      print_basic_message (@message)
      @message = ""
  end

  def restore_buff_status(time_counter, turn, enemy_or_ally)
    time_counter.each_pair do |expire_turn, spell|
      if expire_turn == @turn
        reverse_buff_spell(spell, enemy_or_ally)
      end
    end
  end

  def restore_curse_status(time_counter, turn, enemy_or_ally)
    time_counter.each_pair do |expire_turn, spell|
      if expire_turn == @turn
        reverse_curse_spell(spell, enemy_or_ally)
        time_counter.delete(expire_turn)
      end
    end
  end

  def check_for_status_effects
      restore_buff_status(@ally_buff_counter, @turn, "ally")
      restore_buff_status(@enemy_buff_counter, @turn, "enemy")
      restore_curse_status(@ally_curse_counter, @turn, "ally")
      restore_curse_status(@enemy_curse_counter, @turn, "enemy")
  end

  def clear_out_player_effects
    @ally.hp = @ally.max_hp
    @ally.mana = @ally.max_mana
    @ally_buff_counter.each_pair do |expire_turn, spell|
      @turn = expire_turn
      restore_buff_status(@ally_buff_counter, @turn, "ally")
    end

    @ally_curse_counter.each_pair do |expire_turn, spell|
      @turn = expire_turn
      restore_curse_status(@ally_curse_counter, @turn, "ally")
    end
  end

  def enemy_is_grappled
    display_CBM(@maneuvers, @grappled)
    answer = ask_question("#{@enemy.name.capitalize} is grappled -- what would you like to do?", false, "Pinning an enemy successfully will win the match.")

    if answer == "pin"
      attempt = cbm_attack_attempt(@enemy, @ally)
      if attempt
        print_basic_message("You pin #{@enemy.name.capitalize} to the ground!\n")
        @enemy.hp = -1
        result = check_if_dead
        return result
      else
        @message += "You fail to pin your enemy and they escape from your grasp.\n\n"
        reverse_cbm("enemy", @current_enemy_cbm)
        @current_enemy_cbm = false
        return false
      end
    elsif answer == "release"
      @message += "You release your enemy from your grapple.\n\n"
      reverse_cbm("enemy", @current_enemy_cbm)
      @current_enemy_cbm = false
      return false
    else
      print_error_message("Please type either 'pin' or 'release'.") 
    end
  end

  def update_enemy_cbm
    if @current_enemy_cbm
      case @current_enemy_cbm[:name]
      when "trip"
        print_basic_message("You have tripped your enemy!\n#{@enemy.name.capitalize} attempts to stand but it provokes an attack of oppotunity!\n")
        answer = ask_question("Do you want to take the attack of opportunity?", ["attack", "let him stand"], false)
        if answer == "attack"
          @message += "#{@enemy.name.capitalize} attempts to stand but it provokes an attack of oppotunity!\n"
          @message += "You take the opportunity to attack!\n"
          result = attack_of_opportunity("ally")
          reverse_cbm("enemy", @current_enemy_cbm)
          @current_enemy_cbm = false
          return result
        else
        end
      when "grapple"
        attempt_to_break_grapple = cbm_attack_attempt(@ally, @enemy)
        if attempt_to_break_grapple
          @message += "#{@enemy.name.capitalize} breaks from the grapple!\n\n"
          reverse_cbm("enemy", @current_enemy_cbm)
          @current_enemy_cbm = false
          return false
        else
          @message += "#{@enemy.name.capitalize} fails to break from the grapple!\n\n"
        end
      when "disarm"
        random_chance = rand(1..10)
        if random_chance < 4 # 40% chance
          @enemy.equipped_weapon = @enemy_previous_weapon
          @message += "Enemy re-equips #{@enemy.equipped_weapon[:name]}!\n"
          @current_enemy_cbm = false
          return false
        else
          return enemy_turn
        end
      end
    end
  end

  def attack_of_opportunity(attacker)
    if attacker == "ally"
      player_auto_attack
      return check_if_dead
    elsif attacker == "enemy"
      return enemy_turn
    end
  end

  def player_cast_spell
    valid_answer = false
      while !valid_answer
        display_spell_list(@ally.known_spells)
        answer = ask_question("What spell do you wish to cast?", false, "Type 'back' to leave without casting a spell.")
        if answer == "back"
          system "clear"
          valid_answer = true
          @turn -= 1
          return true
        elsif @ally.known_spells[answer] && @ally.known_spells[answer][:mana_cost] > @ally.mana
          system "clear"
          print_line
          print_error_message("You don't have enough mana to cast #{answer}!")
        elsif @ally.known_spells[answer]
          spell = @ally.known_spells[answer]
          @ally.mana -= spell[:mana_cost]
          if check_if_overcome_spell_failure(@ally)
          system "clear"
            case spell[:type]
            when "damage"
              resisted = check_if_spell_is_resisted(spell, @ally, @enemy)
              if resisted
                @message += "#{@enemy.name} resisted the attack!\n\n"
                return false
              else
                @message += "The spell hits!\n"
                damage = cast_damage_spell(spell, @ally, @enemy)
                @enemy.hp -= damage
                return check_if_dead
              end
            when "healing"
              healing = cast_healing_spell(spell, @ally, @enemy)
              @message += "You heal for #{healing} health\n\n"
              @ally.hp += healing
              return false
            when "buff"
              time = cast_buff_spell(spell, "ally")
              time += @turn + 1
              @ally_buff_counter[time] = spell
              return false
            when "curse"
              resisted = check_if_spell_is_resisted(spell, @ally, @enemy)
              if resisted
                @message += "#{@enemy.name} resisted the curse!\n\n"
              else
                time = cast_curse_spell(spell, "enemy")
                time += @turn + 1
                @enemy_curse_counter[time] = spell
              end
              return false
            end
          else
            return false
          end
        else
          system "clear"
          print_line
          print_error_message("You don't have the spell #{answer}.")
        end
      end
  end

  def player_do_cbm
    valid_answer = false

    while !valid_answer
      display_CBM(@maneuvers, @grappled)
      answer = ask_question("Which Combat Maneuver would you like to preform?", false, "Type 'back' to return.")

    if answer == "back"
        @turn -= 1
        return true
      elsif !@maneuvers[answer]
        print_error_message("That's not a valid combat maneuver. Try again.")
      else
        success = cbm_attack_attempt(@enemy, @ally)
        if success
          if answer == "grapple"
            @grappled = true
          end
          implement_cbm("enemy", @maneuvers[answer])
          @current_enemy_cbm = @maneuvers[answer]
          return false
        else
          return false
        end
      end
    end
  end

  def player_auto_attack
    damage = attack_with_weapon(@ally, @enemy)

    if damage
      @enemy.hp -= damage
    end
  end

  def attack_with_weapon(attacker, target)
    #roll!
    damage = 0
    number_of_attacks = 1
    @message += "#{attacker.name} attacks!\n"
    if attacker.equipped_weapon[:type] == "dual wield weapon"
      number_of_attacks = 2
    end
    number_of_attacks.times do
      die_roll = rand(1..20)
      # check for crit
      if die_roll >= attacker.equipped_weapon[:crit]
        # crit successful!
        @message += "#{attacker.name} crits with a #{die_roll}!"
        damage += roll_for_damage(attacker, true)
      else
        attack = die_roll + attacker.attack
        if attack >= target.ac
          @message += "Attack Roll: #{die_roll} + #{attacker.attack} = #{attack}, Target AC: #{target.ac}\n"
          @message += "#{attacker.name} hits!\n"
          damage += roll_for_damage(attacker, false)
        else
          @message += "Attack Roll: #{die_roll} + #{attacker.attack} = #{attack}, Target AC: #{target.ac}\n"
          @message += "#{attacker.name} misses!\n\n"
        end
      end
    end
    return damage
  end

  def roll_for_damage(attacker, crit)
    die_roll = 0
    damage = 0
    attacker.equipped_weapon[:number_of_dice].times do
      die_roll += rand(1..attacker.equipped_weapon[:dice])
    end
    if crit
      damage = (die_roll + attacker.damage) * attacker.equipped_weapon[:crit_damage]
      if damage < 0
        damage = 0
      end
      @message += "Crit Damage Roll: (#{die_roll} + #{attacker.damage}) * #{attacker.equipped_weapon[:crit_damage]} = #{damage}\n\n"
    else
      damage = die_roll + attacker.damage
      if damage < 0
        damage = 0
      end
      @message += "Damage Roll: #{die_roll} + #{attacker.damage} = #{damage}\n\n"
    end
    return damage
  end

  def check_if_dead
    if @enemy.hp <= 0
      kill = finish_him?(@enemy)
      if kill
        return "kill"
      else
        return "spare"
      end
    else
      return false
    end
  end

  def finish_him?(enemy)
    continue = false
    while !continue
      answer = ask_question("Kill him or spare his life?", ["kill", "spare"], 
                            "Think carefully about your decision as it may have lasting effects.")
      if answer == "kill"
        return true
      elsif answer == "spare"
        return false
      else
        error_message("Please type either 'kill' or 'spare'.")
      end
    end
  end

end


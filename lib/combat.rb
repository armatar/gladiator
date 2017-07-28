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
        elsif result == "kill" || result == "spare"
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

  #will eventually go into enemyai
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

  def check_for_status_effects
    restore_buff_status(@ally_buff_counter, @turn, "ally")
    restore_buff_status(@enemy_buff_counter, @turn, "enemy")
    restore_curse_status(@ally_curse_counter, @turn, "ally")
    restore_curse_status(@enemy_curse_counter, @turn, "enemy")
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

end


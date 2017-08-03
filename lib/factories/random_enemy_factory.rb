require "byebug"

class RandomEnemyFactory

  attr_reader :random_enemy

  def initialize
  end

  def create_random_enemy(enemy, level)
    @random_enemy = enemy
    @random_enemy.character_base
    @random_enemy.set_level(level)
    get_random_character_base
    get_skills
    get_stat_max
    get_random_base_stats
    @random_enemy.set_base_attributes(@str, @dex, @con, @mag, @cha)
    calculate_number_proficiency_points
    set_proficiency_points
    @random_enemy.set_base_proficiency_points(@one_hand_prof, @two_hand_prof, @dual_wield_prof, @magic_prof, @unarmed_prof)
    get_equipped_weapon
    @random_enemy.calculate_initial_stats
    return @random_enemy
  end

  def get_random_character_base
    @str = 8
    @dex = 8
    @con = 8
    @mag = 8
    @cha = 8
    #############
    @one_hand_prof = 0
    @two_hand_prof = 0
    @dual_wield_prof = 0
    @magic_prof = 0 
    @unarmed_prof = 0
  end

  def get_points_to_assign
    points_to_assign = (@random_enemy.level/4).floor + 20
    return points_to_assign
  end

  def get_random_base_stats
    points_to_assign = get_points_to_assign
    counter = 0
    continue = false
    while !continue
      if counter >= points_to_assign
        continue = true
      else
        random_number = rand(1..5)
        case random_number
        when 1
          if ((@str + 1) <= @str_max)
            @str += 1
            counter += 1
          end
        when 2
          if ((@dex + 1) <= @dex_max)
            @dex += 1
            counter += 1
          end
        when 3
          if ((@con + 1) <= @con_max)
            @con += 1
            counter += 1
          end
        when 4
          if ((@mag + 1) <= @mag_max)
            @mag += 1
            counter += 1
          end
        when 5
          if ((@cha + 1) <= @cha_max)
            @cha += 1
            counter += 1
          end
        end  
      end
    end
  end

  def get_skills
    @primary_skill = get_random_skill
    @secondary_skill = get_random_skill
  end

  def calculate_number_proficiency_points
    @proficiency_points = (@random_enemy.level/2).floor + 1
  end

  def set_proficiency_points
    weighted_random_array = [@primary_skill, @primary_skill, @primary_skill, @secondary_skill]

    @proficiency_points.times do
      weighted_random = weighted_random_array.sample
      case weighted_random
      when "1-hand weapon"
        @one_hand_prof += 1
      when "dual wield weapon"
        @dual_wield_prof += 1
      when "2-hand weapon"
        @two_hand_prof += 1
      when "magic"
        @magic_prof += 1
      when "unarmed weapon"
        @unarmed_prof += 1
      end
    end
  end

  def get_stat_max
    case @primary_skill
    when "1-hand weapon", "dual wield weapon", "2-hand weapon", "unarmed weapon"
      if @secondary_skill != "magic"
        @str_max = 99
        @dex_max = 99
        @con_max = 99
        @mag_max = 12
        @cha_max = 12
      else
        @str_max = 99
        @dex_max = 99
        @con_max = 99
        @mag_max = 99
        @cha_max = 99
      end
    when "magic"
      if @secondary_skill == "magic"
        @str_max = 12
        @dex_max = 12
        @con_max = 99
        @mag_max = 99
        @cha_max = 99
      else
        @str_max = 99
        @dex_max = 99
        @con_max = 99
        @mag_max = 99
        @cha_max = 99
      end
    end
  end

  def get_random_skill
    random_number = rand(1..5)
    if random_number == 1
      #1-hand weapon
      return "1-hand weapon"
    elsif random_number == 2
      return "dual wield weapon"
    elsif random_number == 3
      #2-hand weapon
      return "2-hand weapon"
    elsif random_number == 4
      return "magic"
    elsif random_number == 5
      #unarmed
      return "unarmed weapon"
    end
  end

  def get_equipped_weapon
    @random_enemy.item_list.each_pair do |key, value|
      if value[:type] == @primary_skill
        @random_enemy.equipped_weapon = value
        @random_enemy.add_item(key, value)
      elsif value[:type] == "staff"
        if @primary_skill == "magic"
          @random_enemy.equipped_weapon = value
          @random_enemy.add_item(key, value)
        end
      end
    end
  end

  def set_known_spells
  end

  def set_inventory
  end
end

=begin
loop do 
  print "Enter a level: > "
  answer = gets.chomp.to_i
  random_enemy = RandomEnemyFactory.new(answer)
  random_enemy.create_random_enemy("test", "monster")
  random_enemy.random_enemy.display_character_sheet(random_enemy.random_enemy)
end
=end
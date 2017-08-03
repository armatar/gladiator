require "byebug"

class RandomEnemyFactory

  attr_reader :random_enemy, :str, :dex, :con, :mag, :cha

  def initialize
  end

  def get_points_to_assign
    points_to_assign = (@random_enemy.level/4).floor + 20
    return points_to_assign
  end

  def create_random_enemy(enemy, level)
    @random_enemy = enemy
    @random_enemy.character_base
    @random_enemy.set_level(level)
    get_random_character_base
    get_skills
    get_stat_max(@primary_skill, @secondary_skill)
    use_points_to_assign(get_points_to_assign)
    set_proficiency_points(create_weighted_random_array(@primary_skill, @secondary_skill), calculate_number_proficiency_points)
    update_random_enemy
    get_equipped_weapon
    @random_enemy.calculate_initial_stats
    return @random_enemy
  end

  def update_random_enemy
    @random_enemy.set_base_attributes(@str, @dex, @con, @mag, @cha)
    @random_enemy.set_base_proficiency_points(@one_hand_prof, @two_hand_prof, @dual_wield_prof, @magic_prof, @unarmed_prof)
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

  def check_for_valid_random(max, attribute)
    if ((attribute + 1) <= max)
      return true
    else
      return false
    end
  end

  def get_random_number(min, max)
    random_number = rand(min..max)
    return random_number
  end

  def update_random_attribute(random_number, points_to_assign)
    case random_number
    when 1
      if check_for_valid_random(@str_max, @str)
        @str += 1
        return points_to_assign -= 1
      end
    when 2
      if check_for_valid_random(@dex_max, @dex)
        @dex += 1
        return points_to_assign -= 1
      end
    when 3
      if check_for_valid_random(@con_max, @con)
        @con += 1
        return points_to_assign -= 1
      end
    when 4
      if check_for_valid_random(@mag_max, @mag)
        @mag += 1
        return points_to_assign -= 1
      end
    when 5
      if check_for_valid_random(@cha_max, @cha)
        @cha += 1
        return points_to_assign -= 1
      end
    end
    return points_to_assign  
  end

  def use_points_to_assign(points_to_assign)
    while points_to_assign > 0
      points_to_assign = update_random_attribute((get_random_number(1, 5)), points_to_assign)
    end
  end

  def get_skills
    @primary_skill = get_random_skill
    @secondary_skill = get_random_skill
  end

  def calculate_number_proficiency_points
    proficiency_points = (@random_enemy.level/2).floor + 1
    return proficiency_points
  end

  def create_weighted_random_array(primary_skill, secondary_skill)
    weighted_random_array = [primary_skill, primary_skill, primary_skill, secondary_skill]
    return weighted_random_array
  end

  def set_proficiency_points(weighted_random_array, proficiency_points)
    proficiency_points.times do
      case weighted_random_array.sample
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

  def get_stat_max(primary_skill, secondary_skill)
    case primary_skill
    when "1-hand weapon", "dual wield weapon", "2-hand weapon", "unarmed weapon"
      if secondary_skill != "magic"
        @str_max = 99
        @dex_max = 99
        @con_max = 99
        @mag_max = 9
        @cha_max = 12
      else
        @str_max = 99
        @dex_max = 99
        @con_max = 99
        @mag_max = 99
        @cha_max = 99
      end
    when "magic"
      if secondary_skill == "magic"
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
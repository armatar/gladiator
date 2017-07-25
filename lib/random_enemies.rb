require_relative "enemies.rb"

class RandomEnemies
  include Enemies

  def initialize(level)
    @level = level
    @items = Items.new
    @default_weapon = @items.default_weapon["fists"]
    @items = @items.item_list
  end

  def create_random_enemy(name, race)
    @name = name
    @race = race
    get_random_base_stats
    get_random_proficiency
    get_equipped_weapon
    update_modifiers
    calculate_first_hp
    calculate_full_stats
  end

  def get_random_base_stats
    @str = 8
    @dex = 8
    @con = 8
    @mag = 8
    @cha = 8

    points_to_assign = (@level/4) + 20
    points_to_assign.times do
      random_number = rand(1..5)
      case random_number
      when 1
        @str += 1
      when 2
        @dex += 1
      when 3
        @con += 1
      when 4
        @mag += 1
      when 5
        @cha += 1
      end  
    end
  end

  def get_random_proficiency
    continue = false
    random_number = rand(1..5)
    number_prof_points = (@level/3) + 1
    @proficiency = number_prof_points

    while !continue
      if random_number == 1
        #1-hand weapon
        @skill = "1-hand weapon"
        continue = true
      elsif random_number == 2
        @skill = "dual wield weapon"
        continue = true
      elsif random_number == 3
        #2-hand weapon
        @skill = "2-hand weapon"
        continue = true
      elsif random_number == 4
        @skill = "magic"
        continue = true
      elsif random_number == 5
        #unarmed
        @skill = "unarmed weapon"
        continue = true
      end
    end
  end

  #random enemies choose their weapon based on 
  #their proficiency.
  def get_equipped_weapon
    @items.each_pair do |key, value|
      if value[:type] == @skill
        @equipped_weapon = value
      elsif value[:type] == "staff"
        if @skill == "magic"
          @equipped_weapon = value
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
  random_enemy = RandomEnemies.new(answer)
  random_enemy.create_random_enemy("test", "monster")
  random_enemy.print_enemy_stats
end
=end
require_relative "combat_v2.rb"
require_relative "factories/random_enemy_factory.rb"
require_relative "characters/enemies.rb"
require_relative "characters/player_characters/test_character.rb"

class TestingCombat

  def initialize
    @enemy_one = Enemies.new
    @enemy_factory = RandomEnemyFactory.new
    @enemy_one = @enemy_factory.create_random_enemy(@enemy_one, 5)

    @player = TestCharacter.new("Player", "Eastern")
    @player.create_test_character
  end

  def fight
    @fight = Combat.new(@player, @enemy_one, "special event")
    result = @fight.fight!
    if result == "enemy"
      puts "Enemy has died!"
    elsif result == "player"
      puts "Player has died!"
    elsif result == "both"
      puts "Both player and enemy have died!"
    end
  end
end

test = TestingCombat.new
test.fight
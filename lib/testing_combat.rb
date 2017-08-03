require_relative "combat.rb"
require_relative "factories/random_enemy_factory.rb"
require_relative "characters/enemies.rb"
require_relative "characters/player_characters/test_character.rb"

class TestingCombat

  def initialize
    @enemy_one = Enemies.new
    @enemy_factory = RandomEnemyFactory.new
    @enemy_one = @enemy_factory.create_random_enemy(@enemy_one, 2)

    @player = TestCharacter.new("Player", "Eastern")
    @player.create_test_character
  end

  def fight
    @fight = Combat.new(@player, @enemy_one)
    @fight.turn_based_combat
  end
end

test = TestingCombat.new
test.fight
require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class PlayerTurnV2Test < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def test_verify_which_answer
    @mock.expect :call, true
    @combat_session.stub(:player_auto_attack, @mock) do
      @combat_session.verify_which_answer("1")
    end

    @mock.expect :call, true
    @combat_session.stub(:player_use_item, @mock) do
      @combat_session.verify_which_answer("5")
    end
    assert(@mock.verify)
  end

  def test_player_auto_attack
    @combat_session.enemy.ac = 0
    first_hp = @combat_session.enemy.hp
    with_stdin do |user|
      user.puts "1"
      @combat_session.player_auto_attack
    end
    updated_hp = @combat_session.enemy.hp
    assert_operator first_hp, :>, updated_hp,
      "When enemy is hit during player's auto attack, their health should decrease."
  end

  def test_player_get_spell
    spell = {name: "magic missle", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", 
           number_of_dice_bonus: "level", bonus_missles: "proficiency", casting_cost: 15, cost_pool: "mana", price: 150,
           description: "Missles shoot from your fingers toward your opponent. \nDeals 1d4 + cha modifier damage per level."} 

    with_stdin do |user|
      user.puts "magic missle"
      @mock.expect :call, true, [spell]
      @combat_session.stub(:player_cast_spell, @mock) do
        capture_stdout { @combat_session.player_get_spell }
      end
    end
    assert(@mock.verify)
  end

  def test_player_account_for_cost
    spell = {name: "spell with too high a mana cost", casting_cost: 20, cost_pool: "mana"}
    @combat_session.player_character.mana = 100

    assert(@combat_session.player_account_for_cost(spell),
      "When the mana cost is less than or equal to the character's mana, the function should return true.")

    @combat_session.player_character.mana = 0

    assert(!@combat_session.player_account_for_cost(spell),
      "When the mana cost is greater than the character's mana, the function should return false.")
  end

  def test_player_cast_spell
    spell = {name: "magic missle", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", 
           number_of_dice_bonus: "level", bonus_missles: "proficiency", casting_cost: 15, cost_pool: "mana", price: 150,
           description: "Missles shoot from your fingers toward your opponent. \nDeals 1d4 + cha modifier damage per level."} 

    @combat_session.player_character.spell_failure_chance = 0
    @mock.expect :call, nil, [spell]
    @combat_session.stub(:player_coordinate_cast, @mock) do
      @combat_session.player_cast_spell(spell)
    end
    assert(@mock.verify)

    @combat_session.player_character.spell_failure_chance = 100
    @combat_session.enemy.mag_resist = -20
    current_hp = @combat_session.enemy.hp
    @combat_session.player_cast_spell(spell)
    assert_equal(current_hp, @combat_session.enemy.hp,
      "When the player's spell failure chance is 100%, the enemy should never get hit by the spell.")
  end

  def test_spell_pre_checks
    spell = {name: "some healing spell", type: "healing", attribute: "hp"}
    @combat_session.player_character.hp = 10
    @combat_session.player_character.max_hp = 10
    assert(!@combat_session.spell_pre_checks(spell),
      "If the player is attempting to cast a healing spell but the attribute they're affecting is already full, the function should return false.")
  end

  def test_player_coordinate_cast
    spell = @combat_session.player_character.known_spells["magic missle"]
    @mock.expect :call, nil, [spell]
    @combat_session.stub(:player_cast_damage_spell, @mock) do
      @combat_session.player_coordinate_cast(spell)
    end

    spell = @combat_session.player_character.known_spells["cure light wounds"]
    @mock.expect :call, nil, [spell]
    @combat_session.stub(:player_cast_healing_spell, @mock) do
      @combat_session.player_coordinate_cast(spell)
    end
  end

  def test_player_cast_damage_spell
    spell = {name: "magic missle", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", 
           number_of_dice_bonus: "level", bonus_missles: "proficiency", casting_cost: 15, cost_pool: "mana", price: 150,
           description: "Missles shoot from your fingers toward your opponent. \nDeals 1d4 + cha modifier damage per level."} 

    @combat_session.enemy.mag_resist = 100
    starting_hp = @combat_session.enemy.hp 
    @combat_session.player_cast_damage_spell(spell)
    assert_equal(starting_hp, @combat_session.enemy.hp,
      "When the enemy's magic resist is at 100, they should resist the magic and not be damaged.")

    @combat_session.enemy.mag_resist = -20
    @combat_session.player_cast_damage_spell(spell)
    assert_operator starting_hp, :>, @combat_session.enemy.hp, 
      "When the enemy's magic resist is -20, they should never resist a spell and should be hit."
  end
end

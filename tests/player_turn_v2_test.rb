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

end

require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class PlayerCBMTest < Minitest::Test
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

  def test_player_active_cbm_combat_path
    @combat_session.player_set_cbm_status("grappled")
    @mock.expect :call, true
    @combat_session.stub(:player_has_enemy_grappled, @mock) do
      capture_stdout{ @combat_session.player_active_cbm_combat_path }
    end

    with_stdin do |user|
      user.puts "pin"
      @combat_session.enemy_set_cbm_status("grappled")
      @mock.expect :call, true
      @combat_session.stub(:player_is_grappled, @mock) do
        capture_stdout{ @combat_session.player_active_cbm_combat_path }
      end
    end
  end

  def test_player_has_enemy_grappled
    capture_stdout{ with_stdin do |user|
      user.puts "stand"
      assert(!@combat_session.player_has_enemy_grappled,
        "When an invalid action is called, the function should return false")
      user.puts "pin"
      assert(@combat_session.player_has_enemy_grappled,
        "When an valid action is called, the function should return true")
    end }
  end

  def test_player_is_tripped
    capture_stdout{ with_stdin do |user|
      user.puts "pin"
      assert(!@combat_session.player_is_tripped,
        "When an invalid action is called, the function should return false")
      user.puts "stand"
      assert(@combat_session.player_is_tripped,
        "When an valid action is called, the function should return true")
    end}
  end

  def test_player_is_grappled
    capture_stdout{ with_stdin do |user|
      user.puts "pin"
      assert(!@combat_session.player_is_grappled,
        "When an invalid action is called, the function should return false")
      user.puts "gain control"
      assert(@combat_session.player_is_grappled,
        "When an valid action is called, the function should return true")
    end}
  end


end
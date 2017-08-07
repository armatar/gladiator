require_relative "../enemies.rb"

class EnemyForUnitTests < Enemies
  attr_writer :attack, :damage, :equipped_weapon, :ac

  def initialize
    super("Tester", "Human")
  end

  def create_enemy
    @level = 1
    @str = 10 # affects sword/unarmed attack, cbm, cbm_def
    @dex = 10 # affects ac, cbm_def
    @con = 10 # affects hp
    @mag = 10 # affects mag_resist, mag_dc
    @cha = 10 # affects crowd and magic

    @one_hand_prof = 0
    @dual_wield_prof = 0
    @two_hand_prof = 0
    @magic_prof = 0
    @unarmed_prof = 1

    calculate_initial_stats
  end

end
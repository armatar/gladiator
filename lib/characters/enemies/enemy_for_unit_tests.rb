require_relative "../enemies.rb"

class EnemyForUnitTests < Enemies
  attr_writer :attack, :damage, :equipped_weapon, :ac, :hp, :mag_resist

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

    #add_spell_to_known_spells("cure light wounds", @full_spell_list["cure light wounds"])
    add_spell_to_known_spells("magic missle", @full_spell_list["magic missle"])
    add_spell_to_known_spells("beguiler's grace", @full_spell_list["beguiler's grace"])
    add_spell_to_known_spells("shock weapon", @full_spell_list["shock weapon"])
    add_spell_to_known_spells("ray of sickening", @full_spell_list["ray of sickening"])
    add_spell_to_known_spells("ear-piercing scream", @full_spell_list["ear-piercing scream"])

    add_item("bronze sword", @items.item_list["bronze sword"])
    add_item("bronze dual swords", @items.item_list["bronze dual swords"])
    #add_item("health potion", @items.item_list["health potion"])
    add_item("bronze shield", @items.item_list["bronze shield"])
  end

end
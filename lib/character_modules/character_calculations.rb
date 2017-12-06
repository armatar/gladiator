
module CharacterCalculations

  def calculate_initial_stats
    update_modifiers
    set_initiative
    set_first_hp(@level, get_hp_range(@con_modifier), @con_modifier)
    calculate_all_variable_stats
  end

  def calculate_all_variable_stats
    calculate_bab(@level)
    calculate_shield_bonus(@equipped_shield)
    calculate_ac(get_max_dex_bonus_for_ac(@max_dex_bonus_for_ac, @dex_modifier), @shield_bonus, @armor_bonus)
    calculate_weapon_stats
    calculate_magic_resist(@mag_modifier, @cha_modifier, @magic_prof)
    calculate_cbm
    calculate_mana
  end

  def set_first_hp(level, range, con_modifier)
    hp = 0
    level.times do
      hp += rand(range[0]..range[1]) + con_modifier
    end
    @hp = hp
    @max_hp = hp
  end

  def get_hp_range(con_modifier)
    min = 1
    max = 1
    if con_modifier + 1 < 2
      max = 6
    else
      max = 6 * (con_modifier+1)
    end
    min = max/2

    range = [min, max]
    return range
  end

  def calculate_bab(level)
    @bab = (level/2).floor + 1
  end

  def calculate_ac(allowed_dex, shield_bonus, armor_bonus)
    @ac = allowed_dex + shield_bonus + armor_bonus + 10
  end

  def get_max_dex_bonus_for_ac(max_dex_bonus_for_ac, dex_modifier)
    if !max_dex_bonus_for_ac
      allowed_dex = dex_modifier
    else
      allowed_dex = max_dex_bonus_for_ac
    end
    return allowed_dex
  end

  def calculate_shield_bonus(equipped_shield)
    if @equipped_shield
      @shield_bonus = equipped_shield[:defense_bonus] + equipped_shield[:enchantment]
    else
      @shield_bonus = 0
    end
  end

  def calculate_weapon_stats
    set_one_hand
    set_dual_wield
    set_two_hand
    set_unarmed
    set_staff
    set_auto_attack(get_weapon_enchantment(@equipped_weapon), get_attack_and_damage_array)
  end

  def set_one_hand
    @one_hand_atk = get_skill_atk(@one_hand_prof)
    @one_hand_damage = get_skill_damage(@one_hand_prof)
  end

  def set_dual_wield
    @dual_wield_atk = get_skill_atk(@dual_wield_prof)
    @dual_wield_damage = get_skill_damage(@dual_wield_prof)
  end

  def set_two_hand
    @two_hand_atk = get_skill_atk(@two_hand_prof)
    damage = get_skill_damage(@two_hand_prof)
    @two_hand_damage = (damage * 1.5).floor
  end

  def set_unarmed
    @unarmed_atk = get_skill_atk(@unarmed_prof)
    @unarmed_damage = get_skill_damage(@unarmed_prof)
  end

  def set_staff
    @staff_atk = get_skill_atk(@magic_prof)
    @staff_damage = get_skill_damage(@magic_prof)
  end

  def get_weapon_enchantment(equipped_weapon)
    weapon_enchantment = equipped_weapon[:enchantment]
    return weapon_enchantment
  end

  def get_attack_and_damage_array
    attack_and_damage_array = ""
    if @equipped_weapon[:type] == "1-hand weapon"
      attack_and_damage_array = [@one_hand_atk, @one_hand_damage]
    elsif @equipped_weapon[:type] == "2-hand weapon"
      attack_and_damage_array = [@two_hand_atk, @two_hand_damage]
    elsif @equipped_weapon[:type] == "unarmed weapon"
      attack_and_damage_array = [@unarmed_atk, @unarmed_damage]
    elsif @equipped_weapon[:type] == "dual wield weapon"
      attack_and_damage_array = [@dual_wield_atk, @dual_wield_damage]
    elsif @equipped_weapon[:type] == "staff"
      attack_and_damage_array = [@staff_atk, @staff_damage]
    end
    return attack_and_damage_array
  end

  def set_auto_attack(weapon_enchantment, attack_and_damage_array)
    @attack = attack_and_damage_array[0]
    @damage = attack_and_damage_array[1]
  end

  def get_skill_atk(skill)
    attack = @bab + @str_modifier + skill
    return attack
  end

  def get_skill_damage(skill)
    damage = @str_modifier + skill
    return damage
  end

  def calculate_magic_resist(mag_modifier, cha_modifier, magic_prof)
    @mag_resist = mag_modifier + (cha_modifier/2).floor + magic_prof
  end

  #cbm stands for combat maneuver
  def calculate_cbm
    @cbm = @bab + @str_modifier + @unarmed_prof
    @cbm_def = 10 + @bab + @str_modifier + @dex_modifier + @unarmed_prof
  end

  def calculate_mana
    mana = (@magic_prof * 50 ) + (@mag_modifier * 40 ) + (@cha_modifier * 30) + (@level * 20)
    if mana < 0
      mana = 0
    end
    @max_mana = mana
    @mana = @max_mana
    # Level 1, 16 + 3 mag, 14 + 2 cha, 1 prof = 250 mana
    # Level 2, 16 + 3 mag, 14 + 2 cha, 2 prof = 320 mana
    # Level 3, 16 + 3 mag, 14 + 2 cha, 2 prof = 340 mana
    # Level 4, 16 + 3 mag, 14 + 2 cha, 2 prof = 360 mana
    # Level 5, 16 + 3 mag, 14 + 2 cha, 3 prof = 430 mana

    # Level 1, 14 + 2 mag, 12 + 1 cha, 1 prof = 180 mana
    # Level 2, 16 + 3 mag, 14 + 2 cha, 2 prof = 250 mana
    # Level 3, 16 + 3 mag, 14 + 2 cha, 2 prof = 270 mana
    # Level 4, 16 + 3 mag, 14 + 2 cha, 2 prof = 290 mana
    # Level 5, 16 + 3 mag, 14 + 2 cha, 3 prof = 360 mana

    # Level 1, 1 prof = 70 mana  | max of 280 points from modifiers together
    # Level 2, 2 prof = 140 mana | max of 160 points from magic
    # Level 3, 2 prof = 160 mana | max of 120 points from cha
    # Level 4, 2 prof = 180 mana | max of 350 mana at level 1
    # Level 5, 3 prof = 250 mana
  end

  def update_modifiers
    @str_modifier = (@str - 10) / 2
    @dex_modifier = (@dex - 10) / 2
    @con_modifier = (@con - 10) / 2
    @mag_modifier = (@mag - 10) / 2
    @cha_modifier = (@cha - 10) / 2
  end

  def set_initiative
    @init = @dex_modifier
  end

  def get_spell_dc(spell_level)
    mag_dc = 10 + @mag_modifier + (@cha_modifier/2) + @magic_prof + spell_level
    return mag_dc
  end

end

module CharacterCalculations

  def calculate_initial_stats
    update_modifiers
    calculate_first_hp
    calculate_all_variable_stats
  end

  def calculate_all_variable_stats
    calculate_bab
    calculate_ac
    calculate_shield_bonus
    calculate_weapon_stats
    calculate_magic_resist
    calculate_cbm
    calculate_mana
  end

  def calculate_first_hp
    hp = 0
    @level.times do
      if @con_modifier + 1 < 2
        max = 6
      else
        max = 6 * (@con_modifier+1)
      end
      min = max/2
      hp += rand(min..max) + @con_modifier
    end
    @hp = hp
    @max_hp = hp
  end

  def calculate_bab
    @bab = (@level/2) + 1
  end

  def calculate_ac
    if !@max_dex_bonus_for_ac
      allowed_dex = @dex_modifier
    else
      allowed_dex = @max_dex_bonus_for_ac
    end
    if !@shield_bonus
      @shield_bonus = 0
    end

    if !@armor_bonus
      @armor_bonus = 0
    end

    @ac = allowed_dex + @shield_bonus + @armor_bonus + 10
  end

  def calculate_shield_bonus
    if @equipped_shield
      @shield_bonus = @equipped_shield[:defense_bonus] + @equipped_shield[:enchantment]
    else
      @shield_bonus = 0
    end
  end

  def calculate_weapon_stats
    calculate_one_hand
    calculate_dual_wield
    calculate_two_hand
    calculate_unarmed
    calculate_auto_attack
  end

  def calculate_one_hand
    @one_hand_atk = get_skill_atk(@one_hand_prof)
    @one_hand_damage = get_skill_damage(@one_hand_prof)
  end

  def calculate_dual_wield
    @dual_wield_atk = get_skill_atk(@dual_wield_prof)
    @dual_wield_damage = get_skill_damage(@dual_wield_prof)
  end

  def calculate_two_hand
    @two_hand_atk = get_skill_atk(@two_hand_prof)
    damage = get_skill_damage(@two_hand_prof)
    @two_hand_damage = (damage * 1.5).floor
  end

  def calculate_unarmed
    @unarmed_atk = get_skill_atk(@unarmed_prof)
    @unarmed_damage = get_skill_damage(@unarmed_prof)
  end

  def calculate_auto_attack
    @weapon_enchantment = @equipped_weapon[:enchantment]

    if @equipped_weapon[:type] == "1-hand weapon"
      @attack = @one_hand_atk + @weapon_enchantment
      @damage = @one_hand_damage + @weapon_enchantment
    elsif @equipped_weapon[:type] == "2-hand weapon"
      @attack = @two_hand_atk + @weapon_enchantment
      @damage = (@one_hand_damage * 1.5).floor + @weapon_enchantment
    elsif @equipped_weapon[:type] == "unarmed weapon"
      @attack = @unarmed_atk + @weapon_enchantment
      @damage = @unarmed_damage + @weapon_enchantment
    end
  end

  def get_skill_atk(skill)
    attack = @bab + @str_modifier + skill
    return attack
  end

  def get_skill_damage(skill)
    damage = @str_modifier + skill
    return damage
  end

  def calculate_magic_resist
    @mag_resist = @mag_modifier + (@cha_modifier/2).floor + @magic_prof
  end

  #cbm stands for combat maneuver
  def calculate_cbm
    @cbm = @bab + @str_modifier + @unarmed_prof
    @cbm_def = 10 + @bab + @str_modifier + @dex_modifier + @unarmed_prof
  end

  def calculate_mana
    @max_mana = (@magic_prof * 50 ) + (@mag_modifier * 40 ) + (@cha_modifier * 30) + (@level * 20)
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

  def get_magic_dc(spell_level)
    mag_dc = 10 + @mag_modifier + @magic_prof + spell_level
    return mag_dc
  end

end
module PerformCBM
  def cbm_attack_attempt(target, attacker, dice_roll=roll_dice(1,20,1))
    @message += "CMB roll: #{dice_roll} + #{attacker.cbm} = #{dice_roll + attacker.cbm}, Target: #{target.cbm_def}\n"
    attack = dice_roll + attacker.cbm
    if attack >= target.cbm_def
      @message += "CBM attempt successful!\n"
      return true
    else
      @message += "CBM attempt fails. \n\n"
      return false
    end
  end

  def get_cbm_if_exist(cbm_name)
    cbm CombatManeuvers.maneuvers[answer]
    if !cbm
      @message = "#{cbm} is not a valid combat maneuver."
    end
    return cbm
  end
end
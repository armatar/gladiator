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
    cbm = CombatManeuvers.maneuvers[cbm_name]
    if !cbm
      @message = "#{cbm} is not a valid combat maneuver.\n"
    end
    return cbm
  end

  def attempt_to_gain_control(grappled, grappeler, dice_roll=roll_dice(1,20,1))
    @message += "CMB roll: #{dice_roll} + #{grappled.cbm} = #{dice_roll + grappled.cbm}, Target: #{grappeler.cbm_def + 5}\n"
    attack = dice_roll + grappled.cbm
    if attack >= ( grappeler.cbm_def + 5 )
      @message += "CBM attempt successful!\n"
      return true
    else
      @message += "CBM attempt fails. \n\n"
      return false
    end
  end
end
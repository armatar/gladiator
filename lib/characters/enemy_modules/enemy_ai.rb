module EnemyAI
  def attack
    #action = rand(1..6).to_s
    #action = rand(1..3).to_s
    action = "1"
    return get_which_action(action)
  end

  def get_which_spell
    spell = @known_spells[@known_spells.keys.sample]
    return spell_pre_checks(spell)
  end
end
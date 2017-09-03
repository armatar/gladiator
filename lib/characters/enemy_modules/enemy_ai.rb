module EnemyAI
  def attack
    #action = rand(1..6).to_s
    action = "1"
    return get_which_action(action)
  end
end
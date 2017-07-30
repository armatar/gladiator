require "require_all"
require_rel "../characters/enemies"

module SpecificEncounteredEnemies
  def instantiate_enemies
    @first_enemy_wayland = FirstEnemy.new

    set_enemy_stats
  end

  def set_enemy_stats
    @first_enemy_wayland.create_enemy
  end
end
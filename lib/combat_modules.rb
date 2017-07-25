require_relative "status_effects.rb"
require_relative "combat_maneuvers.rb"
require_relative "spell_effects.rb"
require_relative "enemy_ai.rb"

module CombatModules
  include StatusEffects
  include CombatManeuvers
  include SpellEffects
  # include EnemyAI - this guy is still very much under construction.
end
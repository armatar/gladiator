require_relative "status_effects.rb"
require_relative "combat_maneuvers.rb"
require_relative "spell_effects.rb"
require_relative "enemy_ai.rb"
require_relative "player_combat_options.rb"
require_relative "player_combat_specific_interactions.rb"

module CombatModules
  include StatusEffects
  include CombatManeuvers
  include SpellEffects
  include PlayerCombatOptions
  include PlayerCombatSpecificInteractions
  # include EnemyAI - this guy is still very much under construction.
end
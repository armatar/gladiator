require "require_all"
require_rel "combat_v2_modules"

module CombatV2Modules
  include AutoAttack
  include PlayerTurn
  include EnemyTurn
  include CastSpellsPlayer
  include CastSpellsEnemy
  include CastSpell
  include CastDamageSpell
  include CastHealingSpell
  include CombatEffects
end
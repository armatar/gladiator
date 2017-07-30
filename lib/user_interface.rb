require_relative "ui/ui.rb"

module UserInterface
  include UI::Interact
  include UI::CharacterDisplay
  include UI::ItemDisplay
  include UI::DisplayShortcuts
  include UI::StoryDisplay
  include UI::CombatDisplay
  include UI::FinalScreens
  include UI::CBMDisplay
end
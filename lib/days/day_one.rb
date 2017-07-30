module DayOne
  def new_game
    system "clear"

    string = "One month ago to the date, the greatest prophet of this age, the seer, \n" +
             "Iluvia, became a vessel to the God of War, Mythros. He said that he had become \n" +
             "fond of the gladiator games that nobility played and wished to see more. \n" +
             "In order to facilite that, Mythros proclaimed that in three years time, he \n" +
             "would hold a tournament himself to find the greatest gladiator mankind had \n" +
             "to offer. The victor would win from him a boon -- whatever his heart desires. \n \n"

    case @player_character.race
    when "drai"
      string += "You are of the cunning Drai people from a town in the far east \n" +
               "where the deserts are trecherous and the sun is blistering. \n"
    when "relic"
      string += "You are one of the Relic -- a race of people who value the seeking \n" +
               "and preserving of knowledge over everything else. \n"
    when "tiersmen"
      string += "You a Tiersmen, proud and strong. The land you know is the frigid \n" +
               "north where the King's law is weak, and the rule of clans is the norm. \n"
    when "aloiln"
      string += "Your ancestors were sailors and pirates and so you too are called \n" +
               "Aloiln. The many islands to the west is where you grew up, but the \n" +
               "only place you'd truly call home is the sea. \n"
    end

    string += "You, like many others after hearing the Gladiator Promise, have \n" +
              "decided to begin your journey as a Gladiator in the hopes of winning \n" +
              "the Godly wish. Many will perish on the sands of the arena, a sacrifice \n" +
              "to the Bloody God Mythros himself.\n"   

    string += "But you -- you're special, aren't you? A unique among hordes of others? \n\n" +
              "Well, I suppose we'll see."

    write_to_screen(string)
  end

  def first_battle
    system "clear"

    string = "You stand under the blazing sun, the sand beneath your feet, as the roars \n" +
             "of the crowd around you ring in your ears. In the town of Leander, they do not care \n" +
             "if you have no coin or name for all they wish to see is blood. This is where all \n" +
             "gladiators must begin. Though this is only your first fight, you know well that it \n" +
             "may also be your last. \n\n"

    string += "On the other side of the arena, your opponent comes in to view. Like you, he \n" +
              "is ill equipped, perhaps as new to the arena as you. His eyes wander the crowd, \n" +
              "wide and nervous, but as he turns to look at you, he swallows and squares his \n" +
              "shoulders. His gaze seems to say that he will not die this day.\n\n"

    string += "A horn suddenly blares in the distance, signaling the beginning of the battle..."

    write_to_screen(string)

    first_fight = Combat.new(@player_character, @first_enemy_wayland)

    result = first_fight.turn_based_combat
    if result == "dead"
      @player_character.date = -1
      @player_character.hook = -1
      return false
    elsif result == "kill"
      @first_enemy_wayland.kill
      system "clear"

      string = "Your enemy falls before you, food for the carrion that circle overhead. The crowd \n" +
               "cheers but his blood stains your hands.\n\n"
    elsif result == "spare"
      system "clear"

      string = "You allow your enemy to live, much to the displeasure of the crowd. But as the \n"
               "nameless man looks up at you, you find gratitude in his eyes.\n"
    end

    string += "Your head begins to swim, exhaustion and draining adrenline making you weak in the \n" +
               "knees "

    write_to_screen(string)
    @player_character.hook += 1
  end
end
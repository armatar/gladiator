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
    @player_character.hook += 1
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

    first_fight = Combat.new(@player_character, @first_enemy_wayland, "nothing")

    result = first_fight.fight!

    if result == "player" || result == "both"
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

      string = "You allow your enemy to live, much to the displeasure of the crowd. But as the \n" +
               "defeated man looks up at you, you find gratitude in his eyes.\n\n"
    end

    string += "You have won your first victory this day but to reach your dream, you must do more \n" +
              "than fight mindless battles. You know that a key piece to a successful gladiator is \n" +
              "sponsorship. Your two fists and your sheer force of will may have gotten you through \n" +
              "this battle, but to become the greatest gladiator in the eyes of a God, you will need \n" +
              "weapons, armor, experience, exposure -- all things that as you are, would be difficult \n" +
              "if not impossible to come by.\n\n"
    string += "Lucky for you, there were thousands of people to witness your victory. Maybe one of \n" +
              "of them will see in you the potential you see in yourself..."

    write_to_screen(string)
    @player_character.hook += 1
  end

  def meeting_sponsor
    system "clear"
    if @first_enemy_wayland.is_alive
      @sponsor = SponsorWilliam.new
    else
      @sponsor = SponsorTarek.new
    end

    @player_character.sponsor = @sponsor

    string = "You spend some time outside of the arena, hoping that someone will have taken notice, \n" +
             "however the crowd begins to disperse and you've yet to have a single offer. It took you \n" +
             "months to secure a place at the arena as a new, unsponsored, unnamed gladiator, and  \n" +
             "you are aware that you may not be allowed a second chance if you're not picked up today. \n\n"
    string += "The crowd has almost completely gone now and you are preparing yourself to give up for \n" +
              "the day when you hear a call from behind you. \n\n"
    string += '"' + "You there -- gladiator!" + '"' + "\n\n"
    string += "Quickly, you turn to meet the voice, hoping that perhaps luck has finally smiled upon you."

    write_to_screen(string)
    
    system "clear"
    string = @sponsor.introduction
    write_to_screen(string)
  end
end
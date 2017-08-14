require_relative '../user_interface.rb'

module CastBuffSpell
  include UserInterface

  def set_buff_counter(counter, spell, time_to_expire)
    if counter[time_to_expire]
      value = counter[time_to_expire]
      value.push(spell)
      counter[time_to_expire] = value
    else
      counter[time_to_expire] = [spell]
    end
    return counter
  end

  def restore_buff_counter(counter, turn)
    counter.each_pair do |time_to_expire, spells|
      if time_to_expire == turn
        counter.delete(time_to_expire)
      end
    end
    return counter
  end

end
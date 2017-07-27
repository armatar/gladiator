module LevelUpCalculations

  def check_for_new_attribute_points
    level_as_float = @level.to_f
    if ( (level_as_float/4.0) % 1 ).zero?
      @available_attribute_points += 1
    end
  end

  def check_for_new_proficiency_points
    previous_points = @total_proficiency_points 
    proficiency_point_calculation
    new_points = @total_proficiency_points - previous_points
    @available_proficiency_points += new_points
  end

  def proficiency_point_calculation
    @total_proficiency_points = (@level/2).floor + 1
  end

  def calculate_exp_needed_per_level
    level = @level + 1
    @exp_needed = 50*level*(level-1)
  end
end
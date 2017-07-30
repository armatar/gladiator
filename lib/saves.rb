require "yaml"
require_relative "user_interface.rb"

class Saves
  include UserInterface

  attr_reader :saves
  
  def initialize
    @directory = File.dirname(__FILE__)
    @saves = []
    @saves_path = get_full_file_path("saves")
    @saves = YAML.load_file(@saves_path)
  end

  def delete_save(save_to_delete)
    if File.exist?(get_full_file_path(save_to_delete))
      File.delete(get_full_file_path(save_to_delete))
    else
      return false
    end
  end

  def load_save(save_to_load)
    player_character = YAML.load_file(get_full_file_path(save_to_load))
    return player_character
  end

  def load_character
    @saves = YAML.load_file(@saves_path)

    continue = false
    while !continue
      system "clear"
      print_line
      puts Paint["L O A D  G A M E", :white, :bold]
      print_line
      puts Paint["Here are the names of all of your saves in order of earliest to latest: ", :white]
      print_line
      display_saves
      print_line

      answer = ask_question("Which save would you like to load?", false, false)
      if File.exist?(get_full_file_path(answer))
        player_character = load_save(answer)
        system "clear"
        puts "Sweet! We have loaded the character #{player_character.name.capitalize}! \nHere are your current stats:"
        player_character.display_character_sheet_from_character
        return player_character
      else
        answer = ask_question("We don't have a save file for that name. Want to try another?", ["yes", "no"], false)
        if answer.downcase == "yes"
          continue = true
        else
          return false
        end
      end
    end
  end

  def update_saves(save, overwrite)
    if overwrite
      @saves.delete(save)
      @saves.push(save)
    else
      @saves.push(save)
    end

    File.open(@saves_path, "w") do |file|
      file.write(@saves.to_yaml)
    end
  end

  def remove_from_saves_list(save)
    @saves = YAML.load_file(@saves_path)
    @saves.delete(save)
    File.open(@saves_path, "w") do |file|
      file.write(@saves.to_yaml)
    end
  end

  def display_saves
      @saves.each do |save|
        puts save
      end
  end

  def autosave(date, player_character)
    already_exists = false
    if File.exist?(get_full_file_path("#{player_character.name}_#{date}_autosave"))
      already_exists = true
    end
    File.open(get_full_file_path("#{player_character.name}_#{date}_autosave"), "w") do |file|
      file.write(player_character.to_yaml)
    end
    if @saves.length >= 5
      @saves.shift
    end
    if already_exists
      update_saves("#{player_character.name}_#{date}_autosave", true)
    else
      update_saves("#{player_character.name}_#{date}_autosave", false)
    end
    print_line
    puts "Your character has been auto saved..."
    print_line
    gets.chomp
  end

  def get_full_file_path(save_name)
    file = File.join(@directory, "save_files/#{save_name}.yml")
    return file
  end

  def save(save_name, player_character)
    File.open(get_full_file_path(save_name), "w") do |file|
      file.write(player_character.to_yaml)
    end
  end

  def save_character(player_character)
    continue = false
    while !continue
      answer = ask_question["What would you like to name this save?", false, false]
      if File.exist?(get_full_file_path(answer))
        puts "This will overwrite a previous save."
        confirm = double_check
        if confirm
          save(answer, player_character)
          update_saves(answer true)
          continue = true
        else
        end
      else
        save(answer, player_character)
        update_saves(answer, false)
        continue = true
      end
    end
  end
end
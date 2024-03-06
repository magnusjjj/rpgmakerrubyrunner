# This loader is dirty, needs to have contents replaced due to licensing issues. Proof of concept only.

def traceback_report
  backtrace = $!.backtrace.clone
  backtrace.each{ |bt|
    bt.sub!(/Section(\d+)/) {"[#{$1}]#{$RGSS_SCRIPTS[$1.to_i][1]}"}
  }
  return $!.message + "\n\n" + backtrace.join("\n")
end

def raise_traceback_error
  puts($!)
  puts $!.backtrace
  File.open('traceback.log', 'w') { |f| f.write($!) }
  raise 'SyntaxError occurred. Created file traceback.log'
end


class Font

end

module Graphics
    def self.frame_rate
        return 60
    end
    def self.frame_rate=(hoi)
    end
    
    def self.transition(duration = 8, filename = "", vague = 20)
    end

    def self.update
    end

    def self.resize_screen(*arg)
    end
    def self.fullscreen(*arg)
    end
    def self.scale=(*arg)
    end
    def self.center(*arg)
    end
end

class Bitmap
    def draw_text(x, y, width, height, text, align = 0)
    end

    def self.max_size 
        return 0
    end
    def initialize(*arg)
    end
end

class Color
    def initialize(r,g,b,a=255)
    end
end

class Rect
    def initialize(x,y,w,h)
    end
end

module Input
  A = 0
  C = 0
  B = 0
  X = 0
  Y = 0
  Z = 0
  L = 0
  R = 0
  F8 = 0
  def self.update
  end

  def self.trigger?(*arg)
  end
end

class Sprite
    def initialize
    end
    def initialize(blerp)
    end
    def bitmap=(*arg)
    end
    def visible=(*arg)
    end
end


module RPG
    class Sprite
    end
end

module SaveData

end

module System
    def self.data_directory
        return ''
    end
    def self.platform
        return "Windows"
    end
    def self.game_title
        return "Windows"
    end
end

class Viewport
    def initialize(x,y,width,height)
    end

    def z=(number)
    end
end

class Spriteset_Global
    
end

class Tone
    def initialize(h1,h2,h3,h4)
    end
end

module RPG
  module Cache
    @cache = {}
    def self.load_bitmap(folder_name, filename, hue = 0)
      path = folder_name + filename
      if not @cache.include?(path) or @cache[path].disposed?
        if filename != ""
          @cache[path] = Bitmap.new(path)
        else
          @cache[path] = Bitmap.new(32, 32)
        end
      end
      if hue == 0
        @cache[path]
      else
        key = [path, hue]
        if not @cache.include?(key) or @cache[key].disposed?
          @cache[key] = @cache[path].clone
          @cache[key].hue_change(hue)
        end
        @cache[key]
      end
    end
    def self.animation(filename, hue)
      self.load_bitmap("Graphics/Animations/", filename, hue)
    end
    def self.autotile(filename)
      self.load_bitmap("Graphics/Autotiles/", filename)
    end
    def self.battleback(filename)
      self.load_bitmap("Graphics/Battlebacks/", filename)
    end
    def self.battler(filename, hue)
      self.load_bitmap("Graphics/Battlers/", filename, hue)
    end
    def self.character(filename, hue)
      self.load_bitmap("Graphics/Characters/", filename, hue)
    end
    def self.fog(filename, hue)
      self.load_bitmap("Graphics/Fogs/", filename, hue)
    end
    def self.gameover(filename)
      self.load_bitmap("Graphics/Gameovers/", filename)
    end
    def self.icon(filename)
      self.load_bitmap("Graphics/Icons/", filename)
    end
    def self.panorama(filename, hue)
      self.load_bitmap("Graphics/Panoramas/", filename, hue)
    end
    def self.picture(filename)
      self.load_bitmap("Graphics/Pictures/", filename)
    end
    def self.tileset(filename)
      self.load_bitmap("Graphics/Tilesets/", filename)
    end
    def self.title(filename)
      self.load_bitmap("Graphics/Titles/", filename)
    end
    def self.windowskin(filename)
      self.load_bitmap("Graphics/Windowskins/", filename)
    end
    def self.tile(filename, tile_id, hue)
      key = [filename, tile_id, hue]
      if not @cache.include?(key) or @cache[key].disposed?
        @cache[key] = Bitmap.new(32, 32)
        x = (tile_id - 384) % 8 * 32
        y = (tile_id - 384) / 8 * 32
        rect = Rect.new(x, y, 32, 32)
        @cache[key].blt(0, 0, self.tileset(filename), rect)
        @cache[key].hue_change(hue)
      end
      @cache[key]
    end
    def self.clear
      @cache = {}
      GC.start
    end
  end

  class System
    @@start_map_id = 1
    def start_map_id
        puts(@@start_map_id)
        @@start_map_id
    end

    class Words
    end
    class TestBattler
    end




  end

  class AudioFile
  end


end

def load_data(path)
    puts 'loading ' + path
    if ['Data/Animations.rxdata', 'Data/Tilesets.rxdata', 'Data/CommonEvents.rxdata', 'Data/PkmnAnimations.rxdata'].include? path
        return nil
    end
    File.open(path, "rb") { |f|
      obj = Marshal.load(f)
      puts 'done loading'
      return obj
    }
    
end

def load_scripts_from_folder(path)
  files, folders = [], []
  Dir.foreach(path) do |f|
    next if f == '.' || f == '..'
    (File.directory?(File.join(path, f))) ? folders.push(f) :  files.push(f)
  end

  files.sort!
  files.each do |f|
    next if f == "999_Main.rb"
    code = File.open(File.join(path, f), 'r') { |file| file.read }
    begin
      eval(code, nil, f)
    rescue ScriptError
      raise ScriptError.new($!.message)
    rescue
      puts f
      $!.message.sub!($!.message, traceback_report)
      raise_traceback_error
    end
  end

  folders.sort!
  folders.each do |folder|
    load_scripts_from_folder(File.join(path,folder))
  end
end



puts 'started load'
load_scripts_from_folder(File.join(Dir.pwd, File.join('Data', 'Scripts')))
puts 'finished load'

begin
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    #Graphics.update
    #Graphics.freeze
    #clearTempFolder()
    createCustomSpriteFolders()
    begin
        sortCustomBattlers()
    rescue
        echo "failed to sort custom battlers"
    end
    puts GameData::Species.get(1).name
rescue
    $!.message.sub!($!.message, traceback_report)
    raise_traceback_error
end
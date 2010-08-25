# Load the available mods 
def load_mods
   mod_list = (Dir.open "mods").entries.reject do |filename|
      filename[0] == "."
   end
   mods = {} 
   mod_list.each do |mod_name|
      mods[mod_name] = "mods" + mod_name
   end
   mods
end

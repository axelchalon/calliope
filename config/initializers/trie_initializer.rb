# /config/initializers/trie_initializer.rb
# Initialize the Trie data structure containing
# calliope's dictionnary

REFERENCE_TO_SHIRITORI_SERVICE_TO_PREVENT_GARBAGE_COLLECTION = ShiritoriService.instance

Rails.application.config.after_initialize do
  SHIRITORI_DIC = get_shiritori_dic()
  ShiritoriService.instance.set_dic(SHIRITORI_DIC)
end

def get_shiritori_dic
  require 'trie'
  dicpath = Rails.root.join('lib', 'assets', 'gutenberg-utf8.txt')

  dic = Trie.new
  IO.foreach(dicpath) do |word| dic.add word.chomp end

  dic
end

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

  # @TODO JARTE MOI CA @cc @morgan
  do_benchmark = false
  if do_benchmark
    puts "yolo"
    Benchmark.bm do |x|
      rambling_trie = nil
      trietrie = Trie.new

      x.report("Rambling write : ") { rambling_trie = Rambling::Trie.create dicpath}
      x.report("Fast trie write : ") { IO.foreach(dicpath) do |word| trietrie.add word.chomp end}

      x.report("Rambling read : ") { p rambling_trie.has_key?(:staminaux)}
      x.report("Fas trie read : ") { p trietrie.has_key?('staminaux')}

      x.report("Rambling read : ") { p rambling_trie.has_key?(:à)}
      x.report("Fas trie read : ") { p trietrie.has_key?('à')}
    end
    puts "yoli"
  end

  dic = Trie.new
  IO.foreach(dicpath) do |word| dic.add word.chomp end

  dic
end

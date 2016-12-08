# Initialize the Trie data structure containing
# calliope's dictionnary

Rails.application.config.after_initialize do

  require 'trie'
  dicpath = Rails.root.join('lib', 'assets', 'gutenberg-utf8.txt')

  BENCHMARK = false
  if BENCHMARK
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

  TRIE = Trie.new
  IO.foreach(dicpath) do |word| TRIE.add word.chomp end

end

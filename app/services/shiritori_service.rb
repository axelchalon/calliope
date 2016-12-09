class ShiritoriService
  @dic = SHIRITORI_DIC
  @min_word_length = 4

  def initialize(shiritori_dic=nil)
    @dic = shiritori_dic if !shiritori_dic.nil?
  end

  def compute_score(word, time_elapsed=0)
    return 0 unless is_this_word_french? word
    return 0 if word.length < 4
    return word.length - @min_word_length + time_elapsed
  end

  def compute_score!(word, time_elapsed=0)
    raise Exception.new("The word is incorrect!") unless is_this_word_french? word
    return 0 if word.length < 4
    return word.length - @min_word_length + time_elapsed
  end

  def is_this_word_french? word
    @dic.has_key? word
  end

end

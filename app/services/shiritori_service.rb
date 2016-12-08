class ShiritoriService
  @dic = SHIRITORI_DIC

  def initialize(shiritori_dic=nil)
    @dic = shiritori_dic if !shiritori_dic.nil?
  end

  def is_this_word_french? word
    @dic.has_key? word
  end

end

require "rails_helper"
require Rails.root.join("config", "initializers", "trie_initializer.rb")

RSpec.describe ShiritoriService do
  # todo : comment charger le dictionnaire une seule fois pour tous les tests
  # du service ?
  it "checks french words" do
    dic = get_shiritori_dic()
    service = ShiritoriService.new(dic)
    expect(service.is_this_word_french? 'zubeel').to eq(nil)
    expect(service.is_this_word_french? 'bonjour').to eq(true)
  end
end

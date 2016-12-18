require "rails_helper"
require Rails.root.join("config", "initializers", "trie_initializer.rb")

RSpec.describe ShiritoriService do
  # todo : comment charger le dictionnaire une seule fois pour tous les tests
  # du service ?
  it "checks french words" do
    expect(ShiritoriService.instance.is_this_word_french? 'zubeel').to eq(nil)
    expect(ShiritoriService.instance.is_this_word_french? 'bonjour').to eq(true)
  end
end

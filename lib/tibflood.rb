require 'digest/sha1'
require 'bencode'

class Tibflood
  def self.load(filename)
    # We have to open it as binary in order to parse
    # torrent info correctly
    contents = File.open(filename, 'rb') { |io| io.read }
    Bencode.decode(contents)
    binding.pry
  end
end

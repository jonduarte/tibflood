require 'digest/sha1'
require 'bencode'
require 'forwardable'

class Tibflood
  def self.load(filename)
    # We have to open it as binary in order to parse
    # torrent info correctly
    contents = File.open(filename, 'rb') { |io| io.read }
    new(Bencode.decode(contents))
  end

  extend Forwardable
  def_delegator :@bencoded, :[]

  def initialize(bencoded)
    @bencoded = bencoded
  end

  attr_reader :bencoded
  private :bencoded

  def announce
    bencoded['announce']
  end

  def info
    bencoded['info']
  end

  def name
    bencoded['info']['name']
  end
  alias :to_s :name

  def piece_length
    bencoded['info']['piece length']
  end

  def pieces
    bencoded['info']['pieces']
  end

  def files
    bencoded['info']['files']
  end
end

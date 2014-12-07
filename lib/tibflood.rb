require 'digest/sha1'
require 'bencode'
require 'digest/sha1'
require 'securerandom'
require 'uri'

class Tibflood
  TBID      = 'TB'
  TBVERSION = '0001'

  attr_reader :bencoded, :peers

  def initialize(bencoded)
    @bencoded = bencoded
  end

  def add_peers(binary)
    @peers ||= binary
      .split("")
      .each_slice(6)
      .collect(&:join)
      .collect { |s| s.unpack('C4n') }
      .collect { |a| "#{a[0..3].join('.')}:#{a[-1]}" }
  end

  def tracker_url
    params = {
      "info_hash"  => info_hash,
      "peer_id"    => peer_id,
      "port"       => port,
      "uploaded"   => uploaded,
      "downloaded" => downloaded,
      "left"       => left,
      "event"      => 'stopped'
    }

    "#{announce}?#{URI.encode_www_form(params)}"
  end

  def info
    bencoded['info']
  end

  def info_hash
    Digest::SHA1.digest(Bencode.encode(info))
  end

  def peer_id
    @peer_id ||= "-#{TBID}#{TBVERSION}-#{ 12.times.collect { rand(9) }.join }"
  end

  def port
    6881
  end

  def uploaded
    0
  end

  def downloaded
    0
  end

  def left
    piece_length * pieces.size
  end

  def name
    bencoded['info']['name']
  end

  def piece_length
    bencoded['info']['piece length']
  end

  def pieces
    bencoded['info']['pieces']
  end

  def files
    bencoded['info']['files']
  end

  def announce
    bencoded['announce']
  end

  def self.load(filename)
    new(Bencode.decode(File.read(filename, { mode: 'rb' })))
  end
end

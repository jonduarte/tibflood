require 'spec_helper'

describe Tibflood do
  before :all do
    @torrent = Tibflood.load('./spec/sample.torrent')
  end

  it 'load file' do
    expect(@torrent).to be_a(Tibflood)
  end

  it 'has announce url' do
    expect(@torrent.announce).to eq('udp://tracker.publicbt.com:80/announce')
  end

  it 'has info' do
    expect(@torrent['info']).to be_a(Hash)
  end

  it 'has a name' do
    expect(@torrent.name).to eq('GET-STARTED')
  end

  it 'has info piece length' do
    expect(@torrent.piece_length).to eq(262144)
  end

  it 'has multiple files' do
    expect(@torrent.files).to be_an(Array)
  end

  it 'creates sha1 hash to info' do
    expect(@torrent.info_hash.bytesize).to eq(20)
  end

  it 'peer_id is a 20 byte long' do
    expect(@torrent.peer_id.bytesize).to eq(20)
  end

  it 'encode tracker url' do
    peer_id = @torrent.peer_id
    url = "udp://tracker.publicbt.com:80/announce?info_hash=%05%FDS%12%BB%7B9%A0%EEq%E2%8Dt%AD%DD%10%ADe%FF%98&peer_id=#{peer_id}&port=6881&uploaded=0&downloaded=0&left=9337569280&event=stopped"
    expect(@torrent.tracker_url).to eq(url)
  end

  it 'parse peers' do
    peers = "\x7F\x00\x00\x01\x1A\xE1\n\x00\x00\x01\x1A\xE2".force_encoding('BINARY')
    @torrent.add_peers(peers)

    normalized_peers = ["127.0.0.1:6881", "10.0.0.1:6882"]
    expect(@torrent.peers).to eq(normalized_peers)
  end
end

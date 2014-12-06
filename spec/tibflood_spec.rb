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
end

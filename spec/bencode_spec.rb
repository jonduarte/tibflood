require 'spec_helper'

describe Bencode do
  it 'parses string' do
    expect(Bencode.decode('4:spam')).to eq("spam")
  end

  it 'parses integer' do
    expect(Bencode.decode('i3e')).to eq(3)
  end

  it 'parses simple lists' do
    expression = 'l4:spame'
    expect(Bencode.decode('l4:spame')).to eq(["spam"])
  end

  it 'parses complex lists' do
    expression = 'l4:spam4:eggse'
    expect(Bencode.decode(expression)).to eq([ "spam", "eggs" ])
  end

  it 'parses lists with string and integer' do
    expression = 'l4:spam4:eggsi40ee'
    expect(Bencode.decode(expression)).to eq([ "spam", "eggs", 40 ])
  end

  it 'parses dictionary' do
    expression = 'd3:cow3:moo4:spam4:eggse'
    expect(Bencode.decode(expression)).to eq({ "cow" => "moo", "spam" => "eggs" })
  end

  it 'parses complex list' do
    expression = 'd4:spaml1:a1:bee'
    expect(Bencode.decode(expression)).to eq({ "spam" => [ "a", "b" ] })
  end

  it 'parses complex structures' do
    expression = 'd9:publisher3:bob17:publisher-webpage15:www.example.com18:publisher.location4:homee'
    expect(Bencode.decode(expression)).to eq({ "publisher" => "bob", "publisher-webpage" => "www.example.com", "publisher.location" => "home" })
  end
end

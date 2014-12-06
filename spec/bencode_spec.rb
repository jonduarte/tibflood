require 'spec_helper'

describe Bencode do
  context "decode" do
    it 'parses string' do
      expect(Bencode.decode('4:spam')).to eq("spam")
    end

    it 'parses empty string' do
      expect(Bencode.decode('0:')).to eq("")
    end

    it 'parses utf-8 strings' do
      expect(Bencode.decode('3:olá')).to eq("olá")
      expect(Bencode.decode('35:RubyKaigi2009のテーマは、「変わる／変える」です。 前回の')).to eq('RubyKaigi2009のテーマは、「変わる／変える」です。 前回の')
    end

    it 'parses integer' do
      expect(Bencode.decode('i3e')).to eq(3)
    end

    it 'parses negative integer' do
      expect(Bencode.decode('i-3e')).to eq(-3)
    end

    it 'does not parses integer with padding 0' do
      expect { Bencode.decode('i-03e') }.to raise_error(Parslet::ParseFailed)
      expect { Bencode.decode('i03e') }.to raise_error(Parslet::ParseFailed)
      expect(Bencode.decode('i0e')).to eq(0)
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

  context "encode" do
    it 'encode a string' do
      expect(Bencode.encode('olá')).to eq('3:olá')
    end

    it 'encode null string' do
      expect(Bencode.encode('')).to eq('0:')
    end

    it 'encode an integer' do
      expect(Bencode.encode(3)).to eq('i3e')
    end

    it 'encode a simple list' do
      expression = 'l4:spame'
      expect(Bencode.encode(['spam'])).to eq(expression)
    end

    it 'encode lists with string and integer' do
      expression = 'l4:spam4:eggsi40ee'
      expect(Bencode.encode(["spam", "eggs", 40 ])).to eq(expression)
      expect(Bencode.encode(['spam', 40, ''])).to eq('l4:spami40e0:e')
    end

    it 'parses dictionary' do
      expression = 'd3:cow3:moo4:spam4:eggse'
      expect(Bencode.encode({ "cow" => "moo", "spam" => "eggs" })).to eq(expression)
    end

    it 'encode complex structures' do
      expression = 'd9:publisher3:bob17:publisher-webpage15:www.example.com18:publisher.location4:homee'
      expect(Bencode.encode({ "publisher" => "bob", "publisher-webpage" => "www.example.com", "publisher.location" => "home" })).to eq(expression)
    end
  end
end

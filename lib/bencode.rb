require 'strscan'

class Bencode
  def self.decode(value)
    Parser.new(value).parse
  end

  def self.encode(value)
    case value
    when String
      "#{value.size}:#{value}"
    when Fixnum
      "i#{value}e"
    when Array
      encoded = value.collect { |v| encode(v) }.join
      "l#{encoded}e"
    when Hash
      encoded = value.collect { |k, v| encode(k) + encode(v) }.join
      "d#{encoded}e"
    end
  end
end

class Parser < StringScanner
  STRING  = /\d+\:/
  INTEGER = /i/
  LIST    = /l/
  DICT    = /d/

  def parse
    case
    when scan(DICT)    then parse_dict
    when scan(LIST)    then parse_list
    when scan(INTEGER) then parse_int
    when scan(STRING)  then parse_str
    else
      raise ArgumentError, "#{rest} invalid expression"
    end
  end

  private

  def parse_dict
    {}.tap { |dict| loop_matching { dict[parse] = parse } }
  end

  def parse_list
    [].tap { |list| loop_matching { list << parse } }
  end

  def loop_matching
    loop do
      yield
      getch && break if peek(1) == 'e'
    end
  end

  def parse_int
    clean = scan_until(/e/).gsub(/e/, '')
    raise ArgumentError, "#{clean} is an invalid integer" if clean =~ /\A-?0\d+/
    clean.to_i
  end

  def parse_str
    length = matched.split(":").first.to_i
    1.upto(length).collect { getch }.join # Use getch to avoid utf-8 problems
  end
end

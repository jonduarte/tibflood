require 'parslet'

class Bencode
  def self.decode(value)
    tree = Parser.new.parse(value)
    tree = Transformer.new.apply(tree)
    tree.eval
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

  class Parser < Parslet::Parser
    rule(:expression) do
      dictionary | list | string | integer
    end

    rule(:string) do
      digit.repeat(1).capture(:size) >>
        str(':') >>
        dynamic { |_, context|
          max = context.captures[:size].to_i
          max == 0 ?  str("") : any.repeat(max, max)
        }.as(:string)
    end

    rule(:integer) do
      (str('i') >> (str('-').maybe >> match['1-9'] >> digit.repeat | str('0')).as(:integer) >> str('e'))
    end

    rule(:digit) do
      match('[0-9]')
    end

    rule(:list) do
      (str('l') >> expression.repeat(1) >> str('e')).as(:list)
    end

    rule(:dictionary) do
      (str('d') >> (string.as(:key) >> expression.as(:value)).repeat(1) >> str('e')).as(:dictionary)
    end

    root(:expression)
  end

  class Transformer < Parslet::Transform
    rule(:string     => simple(:x))    { StringTransform.new  x }
    rule(:integer    => simple(:x))    { IntegerTransform.new x }
    rule(:list       => sequence(:x))  { ArrayTransform.new   x }
    rule(:dictionary => subtree(:x))   { HashTransform.new    x }
  end

  StringTransform = Struct.new(:x) do
    def eval
      x.to_s
    end
  end

  IntegerTransform = Struct.new(:x) do
    def eval
      x.to_i
    end
  end

  ArrayTransform = Struct.new(:x) do
    def eval
      x.collect { |elem| elem.eval }
    end
  end

  HashTransform = Struct.new(:x) do
    def eval
      {}.tap do |h|
        x.each do |hash|
          key    = hash[:key].eval
          value  = hash[:value].eval
          h[key] = value
        end
      end
    end
  end
end

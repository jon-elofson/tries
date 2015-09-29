require 'byebug'

class TrieNode

  attr_accessor :is_terminal, :children

  def initialize(is_terminal=false)
    @is_terminal = is_terminal
    @children = {}
  end


end


class Trie

  def initialize(words=[])
    @root = TrieNode.new
    words.each do |word|
      self.insert(word)
    end
  end


  def insert(word)
    current = @root
    word.length.times do |idx|
      letter = word[idx]
      child = current.children[letter]
      if child.nil?
        child = TrieNode.new
        current.children[letter] = child
      end
      child.is_terminal = true if idx == (word.length - 1)
      current = child
    end
  end

  def match?(word)
    current = @root
    word.each_char do |chr|
      next_node = current.children[chr]
      if next_node
        current = next_node
      else
        return false
      end
    end
    current.is_terminal
  end

  def find_last_node(prefix)
    current = @root
    prefix.each_char do |chr|
      next_node = current.children[chr]
      if next_node
        current = next_node
      else
        current = nil
      end
    end
    return current
  end

  def all_words
    self.autocomplete('')
  end

  def autocomplete(prefix)
    last_node = find_last_node(prefix)
    if last_node.nil?
      return []
    else
      suffixes = all_suffixes(last_node)
      suffixes.map { |suffix| prefix + suffix }
    end
  end

  def all_suffixes(node)
    if node.children.empty?
       return ['']
    end
    result = []
    children = node.children
    children.each do |ltr,nd|
      next_suffixes = all_suffixes(nd)
      result += next_suffixes.map { |suff| ltr + suff }
    end
    result << '' if node.is_terminal
    result
  end

  def all_prefixes(word)
    prefix = ''
    prefixes = []
    current = @root
    word.each_char do |chr|
      next_node = current.children[chr]
      return prefixes if next_node.nil?
      current = next_node
      prefix += chr
      prefixes << prefix if current.is_terminal && prefix != word
    end
    return prefixes
  end

  def longest_compound
    words = all_words.sort_by { |word| -1 * word.length }
    words.each do |word|
      queue = []
      prefixes = all_prefixes(word)
      prefixes.each do |prefix|
        suffix = word[prefix.length..-1]
        queue << [prefix,suffix]
      end
      until queue.empty?
        compounds = queue.shift
        if compounds.all? { |comp| self.match?(comp) }
          return word
        else
          suffix = compounds[1]
          suffix_prefixes = all_prefixes(suffix)
          suffix_prefixes.each do |pfx|
            new_suffix = suffix[pfx.length..-1]
            queue << [pfx,new_suffix]
          end
        end
      end
    end
    nil
  end




end

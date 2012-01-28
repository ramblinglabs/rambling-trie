require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TrieNode do
  describe 'when creating a node with one letter' do
    trie_node = nil

    before(:each) do
      trie_node = TrieNode.new('a')
    end

    it 'should make it the node letter' do
      trie_node.letter.should == 'a'
    end

    it 'should include no children' do
      trie_node.children.should be_empty
    end

    it 'should be a terminal node' do
      trie_node.terminal?.should be_true
    end
  end

  describe 'when creating a node with two letters' do
    trie_node = nil

    before(:each) do
      trie_node = TrieNode.new('ba')
    end

    it 'should take the first as the node letter' do
      trie_node.letter.should == 'b'
    end

    it 'should include one child' do
      trie_node.children.should_not be_empty
      trie_node.children.length.should == 1
    end

    it 'should include a child with the expected letter' do
      trie_node.children.values.first.letter.should == 'a'
    end
  end

  describe 'when adding a child that already exists' do
    trie_node = nil

    before(:each) do
      trie_node = TrieNode.new('ba')
      trie_node.add_child('a')
    end

    it 'should not increment the child count' do
      trie_node.children.length.should == 1
    end
  end

  describe 'when finding out if a child exists' do
    trie_node = nil

    before(:each) do
      trie_node = TrieNode.new('back')
      trie_node.add_child('ull')
    end

    it 'should return true for an existing child' do
      trie_node.has_child?('a').should be_true
      trie_node.has_child?('ack').should be_true
      trie_node.has_child?('u').should be_true
      trie_node.has_child?('ull').should be_true
    end

    it 'should return false for a non existing child' do
      trie_node.has_child?('b').should be_false
      trie_node.has_child?('x').should be_false
      trie_node.has_child?('ll').should be_false
    end
  end
end
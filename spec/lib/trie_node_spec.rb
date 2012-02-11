require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Rambling
  describe TrieNode do
    describe 'when creating a node with one letter' do
      trie_node = nil

      before(:each) do
        trie_node = TrieNode.new('')
      end

      it 'should make it the node letter' do
        trie_node.letter.should be_nil
      end

      it 'should include no children' do
        trie_node.children.should be_empty
      end

      it 'should be not a terminal node' do
        trie_node.terminal?.should be_false
      end

      it 'should return empty string as its word' do
        trie_node.as_word.should be_empty
      end

      it 'should not be compressed' do
        trie_node.compressed?.should be_false
      end
    end

    describe 'when creating a node with one letter' do
      trie_node = nil

      before(:each) do
        trie_node = TrieNode.new('a')
      end

      it 'should make it the node letter' do
        trie_node.letter.should == :a
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
        trie_node.letter.should == :b
      end

      it 'should include one child' do
        trie_node.children.should_not be_empty
        trie_node.children.length.should == 1
      end

      it 'should include a child with the expected letter' do
        trie_node.children.values.first.letter.should == :a
      end

      it 'should respond to has key correctly' do
        trie_node.has_key?(:a).should be_true
      end

      it 'should return the child corresponding to the key' do
        trie_node[:a].should == trie_node.children[:a]
      end

      it 'should not mark itself as a terminal node' do
        trie_node.terminal?.should be_false
      end

      it 'should mark the first child as a terminal node' do
        trie_node[:a].terminal?.should be_true
      end
    end

    describe 'when creating a large trie node' do
      trie_node = nil

      before(:each) do
        trie_node = TrieNode.new('spaghetti')
      end

      it 'should mark the last letter as terminal node' do
        trie_node[:p][:a][:g][:h][:e][:t][:t][:i].terminal?.should be_true
      end

      it 'should not mark any other letter as terminal node' do
        trie_node[:p][:a][:g][:h][:e][:t][:t].terminal?.should be_false
        trie_node[:p][:a][:g][:h][:e][:t].terminal?.should be_false
        trie_node[:p][:a][:g][:h][:e].terminal?.should be_false
        trie_node[:p][:a][:g][:h].terminal?.should be_false
        trie_node[:p][:a][:g].terminal?.should be_false
        trie_node[:p][:a].terminal?.should be_false
        trie_node[:p].terminal?.should be_false
      end
    end

    describe 'when adding a child that already exists' do
      trie_node = nil

      before(:each) do
        trie_node = TrieNode.new('back')
        trie_node.add_branch_from('a')
      end

      it 'should not increment the child count' do
        trie_node.children.length.should == 1
      end

      it 'should mark it as terminal' do
        trie_node[:a].terminal?.should be_true
      end
    end

    describe 'when getting a node as word' do
      trie_node = nil

      it 'should return the expected word for one letter' do
        trie_node = TrieNode.new('a')
        trie_node.as_word.should == 'a'
      end

      it 'should return the expected word for a small word' do
        trie_node = TrieNode.new('all')
        trie_node[:l][:l].as_word.should == 'all'
      end

      it 'should return the expected word for a small word' do
        trie_node = TrieNode.new('all')
        lambda { trie_node[:l].as_word }.should raise_error(Rambling::InvalidTrieOperation)
      end

      it 'should return the expected word for a long word' do
        trie_node = TrieNode.new('beautiful')
        trie_node[:e][:a][:u][:t][:i][:f][:u][:l].as_word.should == 'beautiful'
      end

      it 'should return nil for an empty node' do
        trie_node = TrieNode.new('')
        trie_node.as_word.should be_empty
      end

      it 'should return nil for a node with nil letter' do
        trie_node = TrieNode.new(nil)
        trie_node.as_word.should be_empty
      end
    end

    describe "when the trie node's parent is compressed" do
      it 'should return true when asked if compressed' do
        trie = double('Rambling::Trie')
        trie.stub(:compressed?).and_return true
        trie_node = TrieNode.new('', trie)

        trie_node.compressed?.should be_true
      end
    end
  end
end

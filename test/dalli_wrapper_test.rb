lib = File.expand_path("../../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'minitest/autorun'
require 'dalli'
require 'cachetagger'

class TestDalliWrapper < MiniTest::Unit::TestCase

  def setup
    @dc = Dalli::Client.new('localhost:11211')
    @tag_wrapper = Cachetagger::DalliWrapper.new(@dc)
  end

  def teardown
    @dc.flush
  end

  def test_add_key_to_new_tag
    key_name = 'new1'
    tag = 'tag1'
    @tag_wrapper.add_key_to_tag(key_name, tag)
    assert_equal("new1",@dc.get(@tag_wrapper.tag_key(tag)))
  end

  def test_add_multi_keys_to_new_tag
    keys = %w{new1 new2}
    tag = 'tag1'
    keys.each do |key_name|
      @tag_wrapper.add_key_to_tag(key_name, tag)
    end
    assert_equal("new1,new2",@dc.get(@tag_wrapper.tag_key(tag)))
  end

  def test_set_tags_for_key 
    key_name = 'new1'
    tags = %w{tag1 tag2 tag3}
    @tag_wrapper.set_tags_for_key(key_name, tags)
    assert_equal("new1",@dc.get(@tag_wrapper.tag_key(tags[0])))
    assert_equal("new1",@dc.get(@tag_wrapper.tag_key(tags[1])))
    assert_equal("new1",@dc.get(@tag_wrapper.tag_key(tags[2])))
    assert_equal("tag1,tag2,tag3",@dc.get(@tag_wrapper.name_key(key_name)))
  end

  def test_invalidate_tag
    key_name = 'new1'
    value = 'val'
    tags = %w{tag1 tag2 tag3}
    @tag_wrapper.set_tags_for_key(key_name, tags)
    @dc.set(key_name, value)

    @tag_wrapper.invalidate_tag('tag2')

    assert_nil @dc.get(key_name)

    assert_equal("",@dc.get(@tag_wrapper.tag_key(tags[0])))
    assert_nil(@dc.get(@tag_wrapper.name_key(key_name)))
  end

  def test_invalidate_multi_key_tag
    key_name = 'new1'
    value = 'val'
    tags = %w{tag1 tag2 tag3}
    @tag_wrapper.set_tags_for_key(key_name, tags)
    @dc.set(key_name, value)
    key_name = 'new2'
    tags = %w{tag2}
    @tag_wrapper.set_tags_for_key(key_name, tags)
    @dc.set(key_name, value)
    key_name = 'new3'
    tags = %w{tag3}
    @tag_wrapper.set_tags_for_key(key_name, tags)
    @dc.set(key_name, value)

    @tag_wrapper.invalidate_tag('tag2')
 
    assert_nil @dc.get('new1')
    assert_nil @dc.get('new2')
    assert_equal(value, @dc.get('new3'))

    assert_equal('new3',@dc.get(@tag_wrapper.tag_key('tag3')))
    assert_equal("",@dc.get(@tag_wrapper.tag_key('tag1')))
    assert_nil(@dc.get(@tag_wrapper.name_key('new2')))
  end

end

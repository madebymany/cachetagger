lib = File.expand_path("../../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'minitest/autorun'
require 'cachetagger'
require 'active_support/cache/cachetagger_store'

class TestActiveSupportCache < MiniTest::Unit::TestCase

  def setup
    @tag_dalli = ActiveSupport::Cache::CachetaggerStore.new('localhost:11211', :expires_in => 1, :race_condition_ttl => 1)
  end

  def teardown
    @dc = Dalli::Client.new('localhost:11211')
    @dc.flush
  end

  def test_write_read_delete
    @tag_dalli.write('new1', 'value1')
    assert_equal("value1",@tag_dalli.read('new1'))
    @tag_dalli.delete('new1')
    assert_nil(@tag_dalli.read('new1'))
  end

  def test_write_read_delete_with_tag
    @tag_dalli.write('new1', 'value1', :tags => ['tag1'])
    assert_equal("value1",@tag_dalli.read('new1'))
    @tag_dalli.delete(nil, :tags => ['tag1'])
    assert_nil(@tag_dalli.read('new1'))
  end
  
  def test_prepare_key_for_tagging_will_namespace_the_key
    # I know what namespaced_key will do (add the namespace to the front 
    # of the key with ':' as a separator)...
    assert_equal 'wow:dave', @tag_dalli.prepare_key_for_tagging('dave', namespace: 'wow')
  end

  def test_prepare_key_for_tagging_will_escape_the_namespaced_key
    # ... but I don't really know what escape_key will do, so we just
    # assert that our method does the same as escape_key would to a
    # namespaced version of the supplied key
    key = 'Wooo!Wooo!' * 26
    assert_equal @tag_dalli.send(:escape_key, 'wow:'+key), @tag_dalli.prepare_key_for_tagging(key, namespace: 'wow')
  end
end

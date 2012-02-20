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
end

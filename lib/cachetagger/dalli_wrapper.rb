# encoding: ascii
begin
  require 'dalli'
rescue LoadError => e
  $stderr.puts "You don't have dalli installed in your application. Please add it to your Gemfile and run bundle install"
  raise e
end

module Cachetagger
  class DalliWrapper
    TAG_PREFIX = 'Cachetagger::Tag::'
    NAME_PREFIX = 'Cachetagger::Name::'

    def tag_key(tag)
      "#{TAG_PREFIX}#{tag}"
    end

    def name_key(name)
      "#{NAME_PREFIX}#{name}"
    end

    def initialize(dalli_client)
      @data = dalli_client
    end

    def add_key_to_tag(key_name,tag)
      unless @data.add(tag_key(tag),key_name)
        @data.cas(tag_key(tag)) do |val|
          current_keys = val.split(',')
          current_keys << key_name unless current_keys.include?(key_name)
          current_keys.join(',')
        end
      end  
    end

    def remove_key_from_tag(tag, key_name)
      @data.cas(tag_key(tag)) do |val|
        current_keys = val.split(',')
        current_keys.delete(key_name)
        current_keys.join(',')
      end
    end

    def delete_key_from_tags(key_name)
      tags = @data.get(name_key(key_name))
      tags.split(',').each {|tag| remove_key_from_tag(tag, key_name)} if tags
    end

    def set_tags_for_key(key_name, tags)
      tags.each {|tag| add_key_to_tag(key_name, tag)}
      @data.set(name_key(key_name), tags.join(','))
    end 

    def invalidate_tag(tag)
      tag_values = @data.get(tag_key(tag))
      unless tag_values.nil?
        tag_values.split(',').each do |cache_key|
          @data.delete(cache_key)
          delete_key_from_tags(cache_key)
          @data.delete(name_key(cache_key))
        end
        @data.delete(tag_key(tag))
      end
    end

  end
end

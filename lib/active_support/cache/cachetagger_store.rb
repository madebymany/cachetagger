# encoding: ascii
begin
  require 'cachetagger'
rescue LoadError => e
  $stderr.puts "You don't have cachetagger installed in your application. Please add it to your Gemfile and run bundle install"
  raise e
end

require 'active_support/cache/dalli_store'

module ActiveSupport
  module Cache

    # A cache store implementation which stores data in Memcached:
    # http://www.danga.com/memcached/
    #
    #CachetaggerStore extends DalliStore and adds some function to tag cache entries
    class CachetaggerStore < DalliStore

      def tag_wrapper
        Cachetagger::DalliWrapper.new(@data)
      end

      def write(name, value, options = nil)
        super(name, value, options)
        options = merged_options(options)
        if options[:tags]
          tag_wrapper.set_tags_for_key(prepare_key_for_tagging(name, options), options[:tags])
        end
      end

      def delete(name, options = nil)
        moptions = merged_options(options)
        if moptions[:tags]
          moptions[:tags].each do |tag|
            tag_wrapper.invalidate_tag(tag)
          end
        end
        unless name.nil?
          super(name,options)
          tag_wrapper.delete_key_from_tags(prepare_key_for_tagging(name, moptions))
        end
      end
      
      def prepare_key_for_tagging(key, options)
        escape_key(
          namespaced_key(key, options)
        )
      end
    end
  end
end

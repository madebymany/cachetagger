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
        tag_wrapper.set_tags_for_key(name, options[:tags]) if !options.nil? && options[:tags]
      end

      def delete(name, options = nil)
        if !options.nil? && options[:tags]
          options[:tags].each do |tag|
            tag_wrapper.invalidate_tag(tag)
          end
        end
        unless name.nil?
          super(name,options)
          tag_wrapper.delete_key_from_tags(name)
        end
      end
    end
  end
end

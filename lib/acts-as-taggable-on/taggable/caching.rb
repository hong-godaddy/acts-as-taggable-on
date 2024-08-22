# frozen_string_literal: true

module ActsAsTaggableOn
  module Taggable
    module Caching
      extend ActiveSupport::Concern

      included do
        before_save :save_cached_tag_list
      end

      class_methods do
        def initialize_tags_cache
          tag_types.map(&:to_s).each do |tag_type|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.caching_#{tag_type.singularize}_list?
              caching_tag_list_on?("#{tag_type}")
            end
              RUBY
          end
        end

        def acts_as_taggable_on(*args)
          super(*args)
          initialize_tags_cache
        end

        def caching_tag_list_on?(context)
          column_names.include?("cached_#{context.to_s.singularize}_list")
        end
      end

      def save_cached_tag_list
        tag_types.map(&:to_s).each do |tag_type|
          if self.class.send("caching_#{tag_type.singularize}_list?") && tag_list_cache_set_on(tag_type)
            list = tag_list_cache_on(tag_type).to_a.flatten.compact.join("#{ActsAsTaggableOn.delimiter} ")
            self["cached_#{tag_type.singularize}_list"] = list
          end
        end

        true
      end
    end
  end
end


module Dino
  module Components
    module Mixins
      module Callbacks
        def after_initialize(options={})
          super
          @callbacks = {}
          @callback_mutex = Mutex.new
        end

        def add_callback(key=:persistent, &block)
          @callback_mutex.synchronize {
            @callbacks[key] ||= []
            @callbacks[key] << block
          }
        end

        def remove_callback(key=nil)
          @callback_mutex.synchronize {
            key ? @new_callbacks[key] = [] : @new_callbacks = {}
          }
        end

        alias :on_data :add_callback
        alias :remove_callbacks :remove_callback

        def update(data)
          @callback_mutex.synchronize {
            @state = data
            callbacks.each_value do |array|
              array.each { |callback| callback.call(@state) }
            end
            remove_callback :read
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Westan
  class Engine < ::Rails::Engine
    engine_name Westan::PLUGIN_NAME
    isolate_namespace Westan
    config.autoload_paths << File.join(config.root, "lib")
  end
end

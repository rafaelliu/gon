class Gon
  module SpecHelper
    module Rails
      extend ActiveSupport::Concern

      module ClassMethods
        module GonSession
          def process(*)
            # preload threadlocal & store controller instance
            controller.gon
            Gon.send(:current_gon).env[Gon::Base::ENV_CONTROLLER_KEY] = controller
            super
          end
        end

        def new(*)
          super.extend(GonSession)
        end
      end
    end
  end
end

if defined?(ActionController::TestCase::Behavior)
  ActionController::TestCase::Behavior.send :include, Gon::SpecHelper::Rails
end


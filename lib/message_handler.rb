module Mantle
  class  MessageHandler
    def receive(action, name, object)
      $stdout << "MessageHandler#receive called.  I am expecting you to override this.\n"
      $stdout << "Args:\n"
      $stdout << "  action: #{action}\n"
      $stdout << "  name: #{name}\n"
      $stdout << "  object: #{object.inspect}\n"
    end
  end
end

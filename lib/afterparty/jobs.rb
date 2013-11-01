module Afterparty

  module JobDescribers
    attr_accessor :clazz, :method, :args, :execute_at

    def initialize object, method, *args
      @object = object
      @method = method
      @args = args
    end

    def description
      desc = "Mailer: #{(@object || "nil")}."
      desc << "Method: #{(@method || "nil")}."
      desc << "Args: #{(@args || "nil")}"
    end
    alias_method :inspect, :description
  end

  class MailerJob
    include JobDescribers

    def run
      @mail = @object.send @method, *@args
      @mail.deliver
    end
  end

  class BasicJob
    include JobDescribers

    def run
      @object.send(@method, *@args)
    end
  end

end
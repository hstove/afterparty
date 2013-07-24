module Afterparty
  class MailerJob
    attr_accessor :execute_at, :mail, :clazz, :method, :args
    def initialize clazz, method, *args
      # @mail = UserMailer.welcome_email(User.find(1))
      @clazz = clazz
      @method = method
      @args = args
    end
    
    def run
      @mail = @clazz.send @method, *@args
      @mail.deliver
    end

    def description
      desc = "Mailer: #{(@clazz || "nil")}."
      desc << "Method: #{(@method || nil)}."
      desc << "Args: #{(@args || nil)}"
    end
  end

  class BasicJob
    attr_accessor :object, :method, :args
    def initialize object, method, *args
      @object = object
      @method = method
      @args = args
    end

    def run
      @object.send(@method, *@args)
    end

    def description
      desc = "Object: #{(@object || "nil")}."
      desc << "Method: #{(@method || nil)}."
      desc << "Args: #{(@args || nil)}"
    end
  end
end
module Afterparty
  class MailerJob
    attr_accessor :execute_at, :mail, :clazz, :method, :args
    def initialize clazz, method, *args
      # @mail = UserMailer.welcome_email(User.find(1))
      @clazz = UserMailer
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
end
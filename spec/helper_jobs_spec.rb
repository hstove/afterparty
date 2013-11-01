require "spec_helper"

describe Afterparty::MailerJob do
  class Mailer
    def self.mail
      self.new
    end

    def deliver
      true
    end
  end

  let(:job){ Afterparty::MailerJob.new Mailer, :mail }

  it "initializes and sets the right attributes" do
    job.args.should eq([])
    job.object.should eq(Mailer)
    job.method.should eq(:mail)
  end

  describe "description" do
    it "describes correctly" do
      description = "Object: Mailer.Method: mail.Args: []"
      job.description.should eq(description)
    end
  end

  it "calls #delivers on the mailer in when ran" do
    Mailer.any_instance.should_receive(:deliver).once
    job.run
  end

end

describe Afterparty::BasicJob do
  class Person
    def say_hello name
      "hello #{name}!"
    end
  end

  ran = false
  let(:job){ Afterparty::BasicJob.new(Person.new, :say_hello, "hank") }

  it "initializes and sets the right attributes" do
    job.args.should eq(["hank"])
    job.object.should be_a(Person)
    job.method.should eq(:say_hello)
  end

  it "sends the given method to @object with @args" do
    Person.any_instance.should_receive(:say_hello).with("hank").once
    job.run
  end

end
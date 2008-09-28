require File.dirname(__FILE__) + '/spec_helper'

class SregUser < ActiveRecord::Base
end

describe ActAsSimpleRegistration do

  describe "acts_as_simple_registration method" do

    it "should set optional sreg attributes with :optional call" do
      model.class.send :acts_as_simple_registration do
        optional :nickname, :email
      end
      model.sreg_optional.should == ['nickname', 'email']
    end

    it "should set required sreg attributes with :required call" do
      model.class.send :acts_as_simple_registration do
        required :nickname, :email
      end
      model.sreg_required.should == ['nickname', 'email']
    end
  
    it "should map keys to themselves when no mapping is given" do
      model.class.send :acts_as_simple_registration do
        optional :nickname
      end
      model.sreg_mapping[:nickname].should == :nickname
    end

    it "should map keys when a mapping is given" do
      model.class.send :acts_as_simple_registration do
        required :nickname => :username
      end
      model.sreg_mapping[:nickname].should == :username
    end
  
    it "should mix optional, required, mappned and non-mapped attributes" do
      model.class.send :acts_as_simple_registration do
        required :email, :nickname => :username, :fullname => :name
        optional :timezone, :dob, :postcode => :zip
      end
      model.sreg_required.sort.should == ['email', 'nickname', 'fullname'].sort
      model.sreg_optional.sort.should == ['timezone', 'dob', 'postcode'].sort
      model.sreg_mapping.should == {
        :nickname => :username,
        :email => :email,
        :fullname => :name,
        :timezone => :timezone,
        :postcode => :zip,
        :dob => :dob
      }
    end

  end

  describe "ruby-openid integration" do
    require 'openid/extensions/sreg'
    
    it "should be useable with OpenID::SReg::Request#request_fields" do
      model.class.send :acts_as_simple_registration do
        required :nickname, :email
        optional :timezone, :dob
      end
      sregreq = OpenID::SReg::Request.new
      sregreq.request_fields model.sreg_required, true
      sregreq.request_fields model.sreg_optional, false
      sregreq.required.sort.should == ['nickname', 'email'].sort
      sregreq.optional.sort.should == ['timezone', 'dob'].sort
    end
  end
  
  describe "assign_sreg_attributes method" do

    it "should assign non-mapped attributes to the model" do
      model.class.send :acts_as_simple_registration do
        optional :email
      end
      model.assign_sreg_attributes 'email' => 'email@test.local'
      model.email.should == 'email@test.local'
    end

    it "should save the model when called with !" do
      model.class.send :acts_as_simple_registration do
        optional :email
      end
      model.should_receive(:save).and_return true
      model.assign_sreg_attributes! 'email' => 'email@test.local'
    end

    it "should not save the model when attribute was not changed" do
      model.class.send :acts_as_simple_registration do
        optional :email
      end
      model.should_receive(:changed?).and_return false
      model.should_not_receive(:save)
      model.assign_sreg_attributes! 'email' => 'email@test.local'
    end

    it "should handle nil" do
      model.class.send :acts_as_simple_registration do
        optional :email
      end
      model.assign_sreg_attributes 'email' => nil
      model.email.should be_blank
    end
    
  end

  private

  def model
    @model ||= stub_model(SregUser)
  end
    
end

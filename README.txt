acts_as_simple_registration
===========================

Use an ActiveRecord model for storing OpenID Simple Registration data.

The following Simple Registration attributes are defined by the specification:

openid.sreg.nickname::
    Any UTF-8 string that the End User wants to use as a nickname.

openid.sreg.email::
    The email address of the End User as specified in section 3.4.1 of
    [RFC2822].

openid.sreg.fullname::
    UTF-8 string free text representation of the End User's full name.

openid.sreg.dob::
    The End User's date of birth as YYYY-MM-DD. Any values whose
    representation uses fewer than the specified number of digits should be
    zero-padded. The length of this value MUST always be 10. If the End User
    user does not want to reveal any particular component of this value, it
    MUST be set to zero.

    For instance, if a End User wants to specify that his date of birth is in
    1980, but not the month or day, the value returned SHALL be "1980-00-00".

openid.sreg.gender:
    The End User's gender, "M" for male, "F" for female.

openid.sreg.postcode:
    UTF-8 string free text that SHOULD conform to the End User's country's
    postal system.

openid.sreg.country:
    The End User's country of residence as specified by ISO3166.

openid.sreg.language:
    End User's preferred language as specified by ISO639.

openid.sreg.timezone:
    ASCII string from TimeZone database 
    For example, "Europe/Paris" or "America/Los_Angeles".

Source: http://openid.net/specs/openid-simple-registration-extension-1_0.html


Example
=======

Given a User model:

  ActiveRecord::Schema.define(:version => 0) do
    create_table :sreg_users, :force => true do |t|
      t.string :name, :email
      t.timestamps
    end
  end

  class User < ActiveRecord::Base
    acts_as_simple_registration do
      required :email
      optional :nickname => :name
    end
  end

Use something like this during an OpenID signin:

In begin phase:

  oidreq = consumer.begin params[:openid_identifier]
  # ...
  sregreq = OpenID::SReg::Request.new
  sregreq.request_fields User.sreg_required, true
  sregreq.request_fields User.sreg_optional, false
  oidreq.add_extension(sregreq)
  # ...  
  redirect_to oidreq.redirect_url(realm, return_to)
  
In complete phase:

  oidresp = consumer.complete(parameters, request_url)
  # ...  
  if oidresp.status == OpenID::Consumer::SUCCESS
    # ...  
    user = User.new
    user.assign_sreg_attributes! OpenID::SReg::Response.from_success_response(oidresp)
    # ...  
  end


Enjoy!


Copyright (c) 2008 Hans-Thomas Mueller =htmue, released under the
CC-GPL version 2 [http://creativecommons.org/licenses/GPL/2.0/].

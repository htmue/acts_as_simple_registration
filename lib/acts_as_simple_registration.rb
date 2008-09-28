module ActAsSimpleRegistration
  def self.included(mod)
    mod.extend(ClassMethods)
  end
  
  SREG_ATTRIBUTES = [:nickname, :email, :fullname, :dob, :gender, :postcode, :country, :language, :timezone]
  
  module ClassMethods
    def acts_as_simple_registration(&block)
      cattr_accessor :sreg_required, :sreg_optional, :sreg_mapping
      self.sreg_required = []
      self.sreg_optional = []
      self.sreg_mapping = {}

      class_eval do
        def self.optional(*attributes)
          sreg_set(false, attributes)
        end

        def self.required(*attributes)
          sreg_set(true, attributes)
        end
        
        def self.valid_sreg_key?(key)
          ActAsSimpleRegistration::SREG_ATTRIBUTES.include? key
        end
        
        private
        
        def self.sreg_set(required, attributes)
          attributes.each do |sreg|
            if sreg.respond_to? :[]
              sreg.keys.each do |key|
                raise ArgumentError unless valid_sreg_key? key
                sreg_set_one(required, key)
                sreg_mapping[key] = sreg[key]
              end
            else
              raise ArgumentError unless valid_sreg_key? sreg
              sreg_set_one(required, sreg)
              sreg_mapping[sreg] = sreg
            end
          end
        end
        
        def self.sreg_set_one(required, key)
          if required
            sreg_required << key.to_s
          else
            sreg_optional << key.to_s
          end
        end
      end
      
      class_eval(&block)

      include ActAsSimpleRegistration::InstanceMethods
    end
  end
  
  module InstanceMethods
    def assign_sreg_attributes(sreg)
      sreg_mapping.each do |model_attribute, sreg_attribute|
        send "#{model_attribute}=", sreg[sreg_attribute]
      end
    end
    
    def assign_sreg_attributes!(sreg)
      assign_sreg_attributes sreg
      save if changed?
    end
  end
end

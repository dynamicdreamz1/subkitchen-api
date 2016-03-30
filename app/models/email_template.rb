class EmailTemplate < ActiveRecord::Base
  validates_with EmailKeysValidator
end

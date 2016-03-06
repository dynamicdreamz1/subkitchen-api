class Company < ActiveRecord::Base
  belongs_to :user
  validates_with CompanyValidator
end

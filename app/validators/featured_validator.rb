class FeaturedValidator < ActiveModel::Validator
	def validate(record)
		return unless record.featured && is_not_an_artist(record)
		record.errors.add(:featured, 'not an an artist')
	end

	private

	def is_not_an_artist(record)
		!record.artist || !record.verified?
	end
end

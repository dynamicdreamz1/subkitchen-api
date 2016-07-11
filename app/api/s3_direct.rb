module S3Direct
	class Api < Grape::API
		resource :s3_direct do
			desc 'get aws s3 credentials'
			params do
				optional :size, type: Integer
				optional :type, type: String
				optional :name, type: String
			end
			get do
				S3DirectService.new(Figaro.env.s3_access_key, Figaro.env.s3_secret, {
					bucket: Figaro.env.s3_bucket,
					acl: 'public-read',
					expiration: "#{10.hours.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')}",
					key: "uploads/#{SecureRandom.uuid}",
					type: params.type
				}).to_json
			end
		end
	end
end

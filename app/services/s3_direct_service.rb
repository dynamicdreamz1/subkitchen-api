require 'openssl'
require 'base64'
require 'json'

class S3DirectService
	def initialize(access_key, secret_key, options = {})
		require_options(options, :bucket, :expiration, :key, :acl)
		@access_key = access_key
		@secret_key = secret_key
		@options = options
	end

	def signature
		Base64.strict_encode64(
			OpenSSL::HMAC.digest('sha1', @secret_key, policy)
		)
	end

	def policy(options = {})
		Base64.strict_encode64(
			{
				expiration: @options[:expiration],
				conditions: [
											{ bucket: @options[:bucket] },
											{ acl: 'public-read' },
											{ expires: @options[:expiration] },
											{ success_action_status: '201' },
											[ 'starts-with', '$key', '' ],
											[ 'starts-with', '$Content-Type', '' ],
											[ 'starts-with', '$Cache-Control', '' ],
											[ 'content-length-range', 0, 524288000 ]
										]
			}.to_json
		)
	end

	def to_json
		{
			acl:            @options[:acl],
			awsaccesskeyid: @access_key,
			policy:         policy,
			signature:      signature,
			key:            @options[:key],
			expires: 				@options[:expiration],
			success_action_status: '201',
			bucket: @options[:bucket],
			'Content-Type' => @options[:type],
			'Cache-Control' => 'max-age=630720000, public'
		}
	end

	private

	def require_options(options, *keys)
		missing_keys = keys.select { |key| !options.key?(key) }
		return unless missing_keys.any?
		raise ArgumentError, missing_keys.map { |key| ":#{key} is required to generate a S3 upload policy." }.join('\n')
	end
end
if Rails.env.production?
  require 'refile/s3'

  aws = {
    access_key_id: Figaro.env.s3_access_key,
    secret_access_key: Figaro.env.s3_secret,
    region: Figaro.env.s3_region,
    bucket: Figaro.env.s3_bucket
  }
  Refile.cache = Refile::S3.new(prefix: 'cache', **aws)
  Refile.store = Refile::S3.new(prefix: 'store', **aws)
end

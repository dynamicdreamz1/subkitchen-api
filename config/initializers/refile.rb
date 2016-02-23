require 'refile/s3'

aws = {
    access_key_id: Rails.application.secrets.s3_access_key,
    secret_access_key: Rails.application.secrets.s3_secret,
    region: "sa-west-1",
    bucket: Rails.application.secrets.s3_bucket,
}
Refile.cache = Refile::S3.new(prefix: "cache", **aws)
Refile.store = Refile::S3.new(prefix: "store", **aws)
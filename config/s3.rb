module Config
  module S3
    module_function

    %i[
      bucket_name access_key_id secret_access_key
      region endpoint
    ].each do |method_name|
      define_method method_name do
        Settings.aws.s3.send(method_name)
      end
    end
  end
end

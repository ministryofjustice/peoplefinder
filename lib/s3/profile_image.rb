module S3

  # wrapper for Aws::S3::Object
  # adds convenience methods for modifying
  # the ACL of the profile image object.
  #
  class ProfileImage

    def initialize object
      @object = object
    end

    # Canned ACls
    # see https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
    # for full list and meaning of each.
    #
    CANNED_ACLS = %w(
      private
      public-read
      public-read-write
      aws-exec-read
      authenticated-read
      bucket-owner-read
      bucket-owner-full-control
      log-delivery-write
    ).freeze

    # define a method for each of the above canned ACLs for convenience
    # e.g. public_read! --> applies the 'public-read' canned-acl to the current object
    #
    CANNED_ACLS.each do |canned_acl_name|
      define_method("#{canned_acl_name.underscore}!".to_sym) do
        acl.put(acl: canned_acl_name)
      end
    end

    def public_read?
      acl.grants.map do |grant|
        grant.permission == 'READ' &&
          grant.grantee.uri.present? &&
          grant.grantee.uri.include?('AllUsers')
      end.any?
    end

    def private?
      !public_read?
    end

    # delegate messages known to the aws s3 bucket object to it
    #
    def method_missing(method_name, *args, &block)
      if @object.respond_to? method_name.to_sym
        @object.__send__(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @object.respond_to?(method_name.to_sym) || super
    end
  end
end

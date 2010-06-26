class SshKey < ActiveRecord::Base
  belongs_to              :user
  validates_format_of     :public_key, :with => %r{^ssh-(rsa|dss)\b}
  validates_uniqueness_of :public_key
  validates_presence_of   :public_key
end

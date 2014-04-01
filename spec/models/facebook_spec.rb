# == Schema Information
#
# Table name: facebooks
#
#  id                         :integer          not null, primary key
#  add_facebook_info_to_users :string(255)
#  uid                        :string(255)
#  oauth_token                :string(255)
#  profile_picture            :string(255)
#  oauth_expires_at           :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  user_id                    :integer
#  provider                   :string(255)
#

require 'spec_helper'

describe Facebook do
  pending "add some examples to (or delete) #{__FILE__}"
end

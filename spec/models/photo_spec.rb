# == Schema Information
#
# Table name: photos
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  url              :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  tweet_id         :integer
#  tweet_created_at :datetime
#

require 'spec_helper'

describe Photo do
  pending "add some examples to (or delete) #{__FILE__}"
end

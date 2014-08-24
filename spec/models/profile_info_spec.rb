# == Schema Information
#
# Table name: profile_infos
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  age           :string(255)
#  interests     :text
#  english_focus :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe ProfileInfo do
  pending "add some examples to (or delete) #{__FILE__}"
end

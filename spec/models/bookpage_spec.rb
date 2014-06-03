# == Schema Information
#
# Table name: bookpages
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  page_number   :integer
#  image         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :integer
#

require 'spec_helper'

describe Bookpage do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: confirmations
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  specific_opening_id :integer
#  confirmed           :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'spec_helper'

describe Confirmation do
  pending "add some examples to (or delete) #{__FILE__}"
end

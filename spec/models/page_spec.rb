# == Schema Information
#
# Table name: pages
#
#  id          :integer          not null, primary key
#  page_number :integer
#  lesson      :string(255)
#  book        :string(255)
#  image       :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Page do
  pending "add some examples to (or delete) #{__FILE__}"
end

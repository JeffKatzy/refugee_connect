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

class Page < ActiveRecord::Base
  attr_accessible :page, :page_number
end

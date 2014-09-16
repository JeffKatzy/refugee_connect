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
#  teachers_page :boolean
#

class Bookpage < ActiveRecord::Base
  attr_accessible :image, :page_number, :title, :photos, :teachers_page
  has_attachments :photos, maximum: 10
  belongs_to :assignment
end

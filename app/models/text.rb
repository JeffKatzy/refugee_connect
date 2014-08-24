# == Schema Information
#
# Table name: texts
#
#  id                :integer          not null, primary key
#  body              :string(255)
#  user_id           :integer
#  unit_of_work_id   :integer
#  unit_of_work_type :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  type              :string(255)
#

class Text < ActiveRecord::Base
  belongs_to :user
  belongs_to :unit_of_work, polymorphic: true
  attr_accessible :unit_of_work_id, :unit_of_work_type, :user_id, :body
end


# == Schema Information
#
# Table name: lessons
#
#  id          :integer          not null, primary key
#  name        :text
#  description :text
#  objectives  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  start_page  :integer
#  finish_page :integer
#

require 'spec_helper'

describe Lesson do
  describe '#appointments' do
  	let(:lesson) { FactoryGirl.create(:lesson)}

  	it "responds to appointments" do
  		expect(lesson.appointments).to_not raise_error
  	end
  end

  describe '#assignments' do
  	let(:lesson) { FactoryGirl.create(:lesson) }

  	it "responds to assignments" do
  		expect(lesson.assignments).to_not raise_error
  	end
  end

  describe '.covers_page' do
    let(:lesson_covering) { FactoryGirl.create(:lesson, start_page: 4, finish_page: 6) }
    let(:other_lesson_covering) { FactoryGirl.create(:lesson, start_page: 6, finish_page: 8) }
    let(:lesson_not_covering) { FactoryGirl.create(:lesson, start_page: 9, finish_page: 12) }
    let(:page_number) { 6 }

    it 'returns lessons where the page is covered' do
      expect(Lesson.covers_page(page_number)).to include(lesson_covering, other_lesson_covering)
      expect(Lesson.covers_page(page_number)).to_not include(lesson_not_covering)
    end
  end
end

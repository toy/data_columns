require File.dirname(__FILE__) + '/spec_helper'

class Person < ActiveRecord::Base
  data_columns :icq, :skype
  data_columns :phone
end

class Worker < Person
  attr_accessor :password
  data_columns :work_phone
end

describe DataColumns do
  it "should store contacts for Person" do
    Person.create(:icq => '12345', :skype => 'vasa', :phone => '56789')
    p = Person.first
    p.icq.should == '12345'
    p.skype.should == 'vasa'
    p.phone.should == '56789'
  end

  it "should store contacts for Worker" do
    Worker.create(:icq => '12345', :skype => 'vasa', :phone => '56789', :work_phone => '367892')
    w = Worker.first
    w.icq.should == '12345'
    w.skype.should == 'vasa'
    w.phone.should == '56789'
    w.work_phone.should == '367892'
  end

  it "should return all data_column_names for Person" do
    Person.data_column_names.should == %w(icq skype phone)
  end

  it "should return all data_column_names for Worker" do
    Worker.data_column_names.should == %w(icq skype phone work_phone)
  end

  it "should return all column_names for Person" do
    Person.column_names.should == %w(id type name data icq skype phone)
  end

  it "should return all column_names for Worker" do
    Worker.column_names.should == %w(id type name data icq skype phone work_phone)
  end

  # it "should track dirty state" do
  #   Person.create(:icq => '12345', :skype => 'vasa', :phone => '56789')
  #   person = Person.first
  #   person.icq = 'ast'
  #   person.changed.should == ['icq']
  #   person.password_will_change!
  #   # person.skype.upcase!
  #   # person.changed.should == ['icq']
  # end

  # it "should track dirty state" do
  #   Person.create(:icq => '12345', :skype => 'vasa', :phone => '56789')
  #   person = Person.first
  #   p person.icq
  #   person.icq = ''
  #   p person.icq_changed?
  #   p person.icq_change
  #   p person.icq_will_change!
  #   p person.icq_was
  #   # person.icq = '23456'
  #   # person.changed.should == ['icq']
  #   # person.password_will_change!
  #   # person.skype.upcase!
  #   # person.changed.should == ['icq']
  # end

end

require File.dirname(__FILE__) + '/spec_helper'

class Person < ActiveRecord::Base
  data_columns :icq, :skype
  data_columns :phone

  data_columns :x, :y, :z, :type => :integer
  data_columns :a, :b, :type => :integer, :default => '123px'
end

class Worker < Person
  data_columns :work_phone
  data_columns :x, :y, :default => 0
end

class Xman < ActiveRecord::Base
  data_columns :name, :field => :cached_data
end

class SubXman < Xman
  data_columns :ability
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

  it "should convert values for column with type" do
    Person.create(:x => '12345px', :y => 'aaa')
    p = Person.first
    p.x.should == 12345
    p.y.should == 0
    p.z.should == nil
  end

  it "should convert and use default for column with type and default" do
    Person.create(:a => nil)
    p = Person.first
    p.a.should == 123
    p.b.should == 123
  end

  it "should add options for inherited columns" do
    Worker.create!(:x => '10px')
    w = Worker.first
    w.x.should == 10
    w.y.should == 0
  end

  it "should return all data_column_names for Person" do
    Person.data_column_names.sort.should == %w(icq skype phone x y z a b).sort
  end

  it "should return all data_column_names for Worker" do
    Worker.data_column_names.sort.should == %w(icq skype phone work_phone x y z a b).sort
  end

  it "should return all column_names for Person" do
    Person.column_names.sort.should == %w(id type name data icq skype phone x y z a b).sort
  end

  it "should return all column_names for Worker" do
    Worker.column_names.sort.should == %w(id type name data icq skype phone work_phone x y z a b).sort
  end

  it "should track dirty state" do
    Person.create(:icq => '12345', :skype => 'vasa', :phone => '56789')

    person = Person.first
    person.icq = nil
    person.changed.should == ['icq']
    person.icq_change.should == ['12345', nil]

    person = Person.first
    person.icq = 'lala'
    person.changed.should == ['icq']
    person.icq_change.should == ['12345', 'lala']
  end
  
  context "having set storing_column_name" do
    
    it "should store a data_column_field" do
      Xman.data_column_field.should == "cached_data"
      Xman.serialized_attributes.keys.should include("cached_data")
    end
    
    it "should inherit a data_column_field" do
      SubXman.data_column_field.should == "cached_data"
    end
    
    it "should store a name" do
      Xman.create(:name => "Iron Man")
      xman = Xman.first
      xman.name.should == "Iron Man"
      xman.cached_data.should == {"name" => "Iron Man"}
    end
    
    it "should store an ability" do
      SubXman.create(:ability => "to fly")
      xman = SubXman.first
      xman.ability.should == "to fly"
    end
    
  end
end

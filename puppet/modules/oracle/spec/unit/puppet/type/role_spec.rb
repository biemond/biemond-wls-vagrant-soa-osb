#!/usr/bin/env rspec

require 'spec_helper'

role = Puppet::Type.type(:role)
InstancesResults = EasyType::Helpers::InstancesResults

describe role do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}


  before :each do
    @class = role
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:simple)
    allow(Puppet::Type::Role).to receive(:defaultprovider).and_return @provider
    @resource = @class.new({:name  => 'CONNECT'})
  end


  it 'should have :name be its namevar' do
    @class.key_attributes.should == [:name]
  end

  describe ':name' do

    let(:attribute_class) { @class.attrclass(:name) }

    it 'should pick its value from element ROLE' do
      raw_resource = InstancesResults['ROLE','MY_ROLE']
      expect(attribute_class.translate_to_resource(raw_resource)).to eq 'MY_ROLE'
    end

    it 'should raise an error when name not found in raw_results' do
      raw_resource = InstancesResults['NO_ROLE','MY_NAME']
      expect{attribute_class.translate_to_resource(raw_resource)}.to raise_error(RuntimeError)
    end

    it 'should accept a name' do
      @resource[:name] = 'CONNECT'
      expect(@resource[:name]).to eq 'CONNECT'
    end

    it 'should munge to uppercase' do
      @resource[:name] = 'connect'
      expect(@resource[:name]).to eq 'CONNECT'
    end
  end


  describe ':password' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :password,
      :raw_value          => 'hhhqhs',
      :test_value         => '',
      :apply_text         =>  "identified by "
    }
  end

end
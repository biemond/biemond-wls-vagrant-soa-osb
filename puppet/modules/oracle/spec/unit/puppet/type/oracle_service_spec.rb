#!/usr/bin/env rspec

require 'spec_helper'

oracle_service = Puppet::Type.type(:oracle_service)
InstancesResults = EasyType::Helpers::InstancesResults

describe oracle_service do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}


  before :each do
    @class = oracle_service
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:simple)
    allow(Puppet::Type::Oracle_service).to receive(:defaultprovider).and_return @provider
    @resource = @class.new({:name  => 'SCOTT'})
  end


  it 'should have :name be its namevar' do
    @class.key_attributes.should == [:name]
  end

  describe ':name' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :name,
      :result_identifier  => 'NAME',
      :raw_value          => 'PIF.infoplus.nl',
      :test_value         => 'PIF.infoplus.nl'
    }
  end


end
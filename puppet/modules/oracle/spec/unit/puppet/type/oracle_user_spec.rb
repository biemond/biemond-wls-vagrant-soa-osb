#!/usr/bin/env rspec

require 'spec_helper'

oracle_user = Puppet::Type.type(:oracle_user)
InstancesResults = EasyType::Helpers::InstancesResults

describe oracle_user do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}


  before :each do
    @class = oracle_user
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:simple)
    allow(Puppet::Type::Oracle_user).to receive(:defaultprovider).and_return @provider
    @resource = @class.new({:name  => 'SCOTT'})
  end


  it 'should have :name be its namevar' do
    @class.key_attributes.should == [:name]
  end

  describe ':name' do

    let(:attribute_class) { @class.attrclass(:name) }

    it 'should pick its value from element USERNAME' do
      raw_resource = InstancesResults['USERNAME','SCOTT']
      expect(attribute_class.translate_to_resource(raw_resource)).to eq 'SCOTT'
    end

    it 'should raise an error when name not found in raw_results' do
      raw_resource = InstancesResults['NO_USERNAME','SCOTT']
      expect{attribute_class.translate_to_resource(raw_resource)}.to raise_error(RuntimeError)
    end

    it 'should accept a name' do
      @resource[:name] = 'SCOTT'
      expect(@resource[:name]).to eq 'SCOTT'
    end

    it 'should munge to uppercase' do
      @resource[:name] = 'scott'
      expect(@resource[:name]).to eq 'SCOTT'
    end

    it 'should not accept a name with whitespace' do
      lambda { @resource[:name] = 'a a' }.should raise_error(Puppet::Error)
    end

    it 'should not accept an empty name' do
      lambda { @resource[:name] = '' }.should raise_error(Puppet::Error)
    end
  end

  describe ':user_id' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :user_id,
      :result_identifier  => 'USER_ID',
      :raw_value          => 500,
      :test_value         => 500,
      :apply_text         => 'set user_id = 500'
    }
  end

  describe ':default_tablespace' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :default_tablespace,
      :result_identifier  => 'DEFAULT_TABLESPACE',
      :raw_value          => 'USERS',
      :test_value         => 'USERS',
      :apply_text         => "default tablespace USERS"
    }
  end

  describe ':temporary_tablespace' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :temporary_tablespace,
      :result_identifier  => 'TEMPORARY_TABLESPACE',
      :raw_value          => 'TEMP',
      :test_value         => 'TEMP',
      :apply_text         => "temporary tablespace TEMP"
    }
  end

  describe ':password' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :password,
      :result_identifier  => 'PASSWORD',
      :raw_value          => 'password',
      :test_value         => 'password',
      :apply_text         => "identified by password"
    }
  end


  describe ':quotas' do

    it "must be specced and tested"

  end

  describe ':grants' do

    it "must be specced and tested"

  end


end
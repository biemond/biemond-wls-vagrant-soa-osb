#!/usr/bin/env rspec

require 'spec_helper'

oracle_exec = Puppet::Type.type(:oracle_exec)

describe oracle_exec do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}


  before :each do
    @class = oracle_exec
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:sqlplus)
    allow(Puppet::Type::Oracle_exec).to receive(:defaultprovider).and_return @provider
    @resource = @class.new({:title  => 'show_all'})
  end

  describe ':statement' do

    it 'should have :statement property' do
      @class.properties.map(&:name).should include(:statement)
    end
  end

  describe ':logoutput' do

    it 'should have :logoutput attribute' do
      @class.parameters.should include(:logoutput)
    end
  end

  describe ':username' do

    it 'should have :username attribute' do
      @class.parameters.should include(:username)
    end
  end

  describe ':password' do

    it 'should have :password attribute' do
      @class.parameters.should include(:password)
    end
  end


end
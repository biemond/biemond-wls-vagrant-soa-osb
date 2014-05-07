#!/usr/bin/env rspec

require 'spec_helper'

tablespace = Puppet::Type.type(:tablespace)
InstancesResults = EasyType::Helpers::InstancesResults

describe tablespace do

  let(:attribute_class) {  @class.attrclass(attribute_name) }
  let(:attribute) {@resource.property(attribute_name)}


  before :each do
    @class = tablespace
    @provider = double 'provider'
    allow(@provider).to receive(:name).and_return(:simple)
    allow(Puppet::Type::Tablespace).to receive(:defaultprovider).and_return @provider
    @resource = @class.new({:name  => 'PII_DATA'})
  end


  it 'should have :name be its namevar' do
    @class.key_attributes.should == [:name]
  end

  describe ':name' do

    let(:attribute_class) { @class.attrclass(:name) }

    it 'should pick its value from element TABLESPACE_NAME' do
      raw_resource = InstancesResults['TABLESPACE_NAME','MY_NAME']
      expect(attribute_class.translate_to_resource(raw_resource)).to eq 'MY_NAME'
    end

    it 'should raise an error when name not found in raw_results' do
      raw_resource = InstancesResults['NAME','MY_NAME']
      expect{attribute_class.translate_to_resource(raw_resource)}.to raise_error(RuntimeError)
    end

    it 'should accept a name' do
      @resource[:name] = 'PII_DATA'
      expect(@resource[:name]).to eq 'PII_DATA'
    end

    it 'should munge to uppercase' do
      @resource[:name] = 'system'
      expect(@resource[:name]).to eq 'SYSTEM'
    end

    it 'should not accept a name with whitespace' do
      lambda { @resource[:name] = 'a a' }.should raise_error(Puppet::Error)
    end

    it 'should not accept an empty name' do
      lambda { @resource[:name] = '' }.should raise_error(Puppet::Error)
    end
  end


  describe ':logging' do

    let(:attribute_name) { :logging}

    context "when geting data from the system" do


      it 'should raise an error when name not found in raw_results' do
        raw_resource = InstancesResults['NAME','MY_NAME']
        expect{attribute_class.translate_to_resource(raw_resource)}.to raise_error(RuntimeError)
      end

      it 'should pick its value from element LOGGING and translate value LOGGING to :yes' do
        raw_resource = InstancesResults['LOGGING','LOGGING']
        expect(attribute_class.translate_to_resource(raw_resource)).to eq :yes
      end

      it 'should pick its value from element LOGGING and translate value NOLOGGING to :no' do
        raw_resource = InstancesResults['LOGGING','NOLOGGING']
        expect(attribute_class.translate_to_resource(raw_resource)).to eq :no
      end

      it 'raise an error if value is not LOGGING or NOLOGGING ' do
        raw_resource = InstancesResults['LOGGING','UNKNOWN']
        expect{attribute_class.translate_to_resource(raw_resource)}.to raise_error(RuntimeError)
      end
    end

    context "on applying the resource" do

      context "logging is :yes" do

        before do
          @resource[:logging] = :yes
        end

        it "returns 'logging'" do
          expect(attribute.on_apply).to eq 'logging'
        end
      end

      context "logging is :no" do

        before do
          @resource[:logging] = :no
        end

        it "returns 'nologging'" do
          expect(attribute.on_apply).to eq 'nologging'
        end
      end
    end

    context "base parameter settings" do
      it 'should accept a yes' do
        @resource[:logging] = 'yes'
        expect(@resource[:logging]).to eq :yes
      end

      it 'should accept a no' do
        @resource[:logging] = 'no'
        expect(@resource[:logging]).to eq :no
      end


      it 'should not accept true' do
        lambda { @resource[:logging] = 'true' }.should raise_error(Puppet::Error)
      end

      it 'should not accept false' do
        lambda { @resource[:logging] = 'false' }.should raise_error(Puppet::Error)
      end

      it 'should not accept any other string then yes or no' do
        lambda { @resource[:logging] = 'hdjhdh' }.should raise_error(Puppet::Error)
      end
    end

  end


  describe ':size' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :size,
      :result_identifier  => 'BYTES',
      :raw_value          => '1000',
      :test_value         => 1000,
      :apply_text         => 'datafile size 1000'
    }
  end

  describe ':datafile' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :datafile,
      :result_identifier  => 'FILE_NAME',
      :raw_value          => 'a_file_name.txt',
      :test_value         => 'a_file_name.txt',
      :apply_text         => "datafile 'a_file_name.txt'"
    }


    context "base parameter settings" do
      it 'should accept a string' do
        @resource[:datafile] = 'a_file_name.txt'
        expect(@resource[:datafile]).to eq 'a_file_name.txt'
      end
    end
  end

  describe ':extent_management' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :extent_management,
      :result_identifier  => 'EXTENT_MAN',
      :raw_value          => 'LOCAL',
      :test_value         => :local,
      :apply_text         => 'extent management local'
    }

  end


  describe ':segment_space_management' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :segment_space_management,
      :result_identifier  => 'SEGMEN',
      :raw_value          => 'AUTO',
      :test_value         => :auto,
      :apply_text         => "segment space management auto"
    }

  end

  describe ':bigfile' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :bigfile,
      :result_identifier  => 'BIG',
      :raw_value          => 'YES',
      :test_value         => :yes
    }

  end


  describe ':autoextend' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :autoextend,
      :result_identifier  => 'AUT',
      :raw_value          => 'YES',
      :test_value         => :on,
      :apply_text         => "autoextend on"
    }

  end


  describe ':next' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :next,
      :raw_resource       => { 'BLOCK_SIZE' => '1024', 'INCREMENT_BY' => '100'},
      :test_value         => 102400,
      :apply_text         => 'next 102400'
    }

  end

  describe ':max_size' do

    it_behaves_like 'an easy_type attribute', {
      :attribute          => :max_size,
      :result_identifier  => 'MAX_SIZE',
      :raw_value          => '1000000.123',
      :test_value         => 1000000,
      :apply_text         => "maxsize 1000000"
    }

  end


end
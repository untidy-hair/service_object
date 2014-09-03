require 'spec_helper'

class DummyService < ServiceObject::Base; end

describe ServiceObject::Base do
  subject { DummyService.new }

  it 'has ServiceObject::Errors instance as an instance variable' do
    expect(subject.instance_variable_get(:@errors).class).to eq ServiceObject::Errors
  end

  it 'has @result as true after instantiation' do
    expect(subject.instance_variable_get(:@result)).to be true
  end

  describe '#error_messages' do
    it 'returns @errors full_messages' do
      expect(subject.error_messages).to eq subject.errors.full_messages
      subject.errors.add 'Error Message 1'
      expect(subject.error_messages).to eq subject.errors.full_messages
      subject.errors.add 'Error Message 2'
      expect(subject.error_messages).to eq subject.errors.full_messages
    end
  end

  describe '#result' do
    context 'When @result is true and @errors are empty' do
      it 'returns true' do
        expect(subject.result).to be true
      end
    end

    context 'When @result is false' do
      it 'returns false' do
        subject.instance_variable_set(:@result, false)
        expect(subject.result).to be false
      end
    end

    context 'When @result is true but @errors are not empty' do
      it 'returns false' do
        subject.errors.add 'Error added!'
        expect(subject.result).to be false
      end
    end
  end

  describe '-#flattened_active_model_error' do
    it 'returns error info of given active model instance as string' do
      class DummyActiveModel
        include ActiveModel::Model
        attr_reader :name, :age
        validates :name, presence: true
        validates :age, numericality: { only_integer: true }
      end
      dummy_model = DummyActiveModel.new
      dummy_model.valid?
      expect(subject.__send__(:flattened_active_model_error, dummy_model)).
        to eq 'DummyActiveModel: Name can\'t be blank, Age is not a number'
    end
  end

  # ToDo: How to expect messages with a block
  describe '.transaction' do
    it 'delegates to ActiveRecord::Base.transaction' do
      expect(ActiveRecord::Base).to receive(:transaction)
      described_class.transaction { 'hoge' }
    end
  end

  describe '#transaction' do
    it 'delegates to .transaction' do
      expect(described_class).to receive(:transaction)
      subject.transaction { 'hoge' }
    end
  end
end

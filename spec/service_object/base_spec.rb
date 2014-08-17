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
end

require 'spec_helper'

describe ServiceObject::Errors do
  # This example is not comprehensive
  it 'delegates to @messages' do
    messages = subject.messages
    [:unshift, :push, :<<].each do |method|
      expect(messages).to receive(method).with(100)
      subject.__send__(method, 100)
    end
  end

  describe '#add' do
    it 'adds new error(s) to @messages' do
      subject.add 'Error 1'
      expect(subject.messages).to eq ['Error 1']
      subject.add 'Error 2'
      expect(subject.messages).to eq ['Error 1', 'Error 2']
    end
  end

  describe '#full_message' do
    it 'returns the same value as @messages' do
      subject.add 'Error 1'
      expect(subject.full_messages).to eq subject.messages
      subject.add 'Error 2'
      expect(subject.full_messages).to eq subject.messages
    end
  end

  describe '#to_xml' do
    it 'returns a xml format string' do
      subject.add 'Something went wrong.'
      subject.add 'Another error happened.'
      expect(subject.to_xml).to eq <<-XML
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<errors>
  <error>Something went wrong.</error>
  <error>Another error happened.</error>
</errors>
      XML
    end
  end

  describe '#as_json' do
    before { subject.add 'Test error happened' }
    it 'returns messages as an Array' do
      expect(subject.as_json).to eq subject.messages
      expect(subject.as_json).to be_a Array
    end
  end

end

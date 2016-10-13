require_relative '../spec_helper.rb'

describe 'message' do
  before(:each) do
    @message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      body: 'HT/YXj2GT08A0OBkjP//Bw==',
      iv: 'H10I/DYZgBS5jAKG87P43A==',
      visits_to_live: -1,
      hours_to_live: -1
    )
  end

  it 'should exists' do
    expect(@message).to be_an_instance_of(Message)
  end

  it 'is valid' do
    expect(@message).to be_valid
  end

  it 'requires a body' do
    @message = Message.new
    expect(@message).to_not be_valid
    expect(@message.errors[:body]).to include('Body must not be blank')
  end

  it 'should proper store attributes' do
    @message.save
    @message_test = Message.get(@message.id)
    expect(@message_test.body).to eq('HT/YXj2GT08A0OBkjP//Bw==')
  end
end

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

  it 'correctly encrypt message' do
    message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      raw_message: 'test message',
      iv: 'H10I/DYZgBS5jAKG87P43A=='
    )
    message.encrypt!('aes-256-cbc', 'l3:x\@#W@Z9;1.WDhcAU*yM--FcFBJX')
    expect(message.body).to eq('HT/YXj2GT08A0OBkjP//Bw==')
  end

  it 'correctly decrypt message' do
    message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      body: 'HT/YXj2GT08A0OBkjP//Bw==',
      iv: 'H10I/DYZgBS5jAKG87P43A=='
    )
    message.decrypt!('aes-256-cbc', 'l3:x\@#W@Z9;1.WDhcAU*yM--FcFBJX')
    expect(message.raw_message).to eq('test message')
  end

  it 'correctly checks hours to live (hours expired)' do
    message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      created_at: DateTime.now,
      hours_to_live: 1
    )
    time = DateTime.now + (1.1 / 24.0)
    Timecop.freeze(time) do
      expect(message.check_hours_to_live?).to be false
    end
  end

  it 'correctly checks hours to live (hours not expired)' do
    message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      created_at: DateTime.now,
      hours_to_live: 2
    )
    time = DateTime.now + (1.1 / 24.0)
    Timecop.freeze(time) do
      expect(message.check_hours_to_live?).to be true
    end
  end

  it 'correctly checks visits to live (visits expired)' do
    message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      visits_to_live: 0
    )
    expect(message.check_visits_to_live?).to be false
  end

  it 'correctly checks visits to live (visits not expired)' do
    message = Message.create(
      id: 'd2fa379b221ca08838358da6d8266380',
      body: 'HT/YXj2GT08A0OBkjP//Bw==',
      visits_to_live: 1
    )
    expect(message.check_visits_to_live?).to be true
  end

  it 'loads saved messages' do
    @message.save
    message_test = Message.load_message('d2fa379b221ca08838358da6d8266380')
    expect(@message).to eq(message_test)
  end
end

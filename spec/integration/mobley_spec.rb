require_relative '../spec_helper.rb'

describe 'Mobley Application Integration' do
  it 'should allow to access the main page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'main page should return html page' do
    get '/'
    expect(last_response.headers['Content-Type']).to eq 'text/html;charset=utf-8'
  end

  it 'should allow to save message' do
    post '/', message: 'test message'
    expect(last_response).to be_ok
  end

  it 'should allow to save message (with visits_to_live)' do
    post '/', message: 'test message', visits_to_live: '1'
    expect(last_response).to be_ok
  end

  it 'should allow to save message (with hours_to_live)' do
    post '/', message: 'test message', hours_to_live: '1'
    expect(last_response).to be_ok
  end

  it 'shouldn\'t allow to save message with visits_to_live & hours_to_live' do
    post '/', message: 'test message', visits_to_live: '1', hours_to_live: '1'
    expect(last_response).to be_bad_request
  end

  it 'saved message should be accessiable by link' do
    @message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      body: 'HT/YXj2GT08A0OBkjP//Bw==',
      iv: 'H10I/DYZgBS5jAKG87P43A==',
      visits_to_live: -1,
      hours_to_live: -1
    )
    @message.save
    get "/message/#{@message.id}"
    expect(last_response).to be_ok
    response_message = last_response.body.scan(%r{document\.write\("<p><b>Message: <\/b>(.+)"\);}).join('')
    expect(response_message).to eq('test message')
  end

  it 'saved message with visits_to_live=n should expire after "n" requests (n=1)' do
    @message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      body: 'HT/YXj2GT08A0OBkjP//Bw==',
      iv: 'H10I/DYZgBS5jAKG87P43A==',
      visits_to_live: 1,
      hours_to_live: -1
    )
    @message.save
    get "/message/#{@message.id}"
    expect(last_response).to be_ok
    get "/message/#{@message.id}"
    expect(last_response).to be_not_found
  end

  it 'saved message with visits_to_live=n should expire after "n" requests (n=2)' do
    @message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      body: 'HT/YXj2GT08A0OBkjP//Bw==',
      iv: 'H10I/DYZgBS5jAKG87P43A==',
      visits_to_live: 2,
      hours_to_live: -1
    )
    @message.save
    get "/message/#{@message.id}"
    expect(last_response).to be_ok
    get "/message/#{@message.id}"
    expect(last_response).to be_ok
    get "/message/#{@message.id}"
    expect(last_response).to be_not_found
  end

  it 'saved message with hours_to_live=n should expire after "n" hours (n=1)' do
    @message = Message.new(
      id: 'd2fa379b221ca08838358da6d8266380',
      body: 'HT/YXj2GT08A0OBkjP//Bw==',
      iv: 'H10I/DYZgBS5jAKG87P43A==',
      visits_to_live: -1,
      hours_to_live: 1
    )
    @message.save
    time = DateTime.now + (1.1 / 24.0)
    Timecop.freeze(time) do
      get "/message/#{@message.id}"
      expect(last_response).to be_not_found
    end
  end
end

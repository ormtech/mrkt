describe Mrkt::Client do
  include_context 'initialized client'

  it "uses an existing Faraday connection when provided" do
    logger_double = instance_double("::Logger", debug: "Debugging", info: "Info")

    conn = Faraday.new do |builder|
      builder.response :logger, logger_double
      builder.adapter :test do |stub|
        stub.get('/ebi') { |env| [ 200, {}, 'shrimp' ]}
      end
    end

    client = Mrkt::Client.new(host: host, client_id: client_id, client_secret: client_secret, connection: conn)

    expect(client.connection.get('/ebi').body).to eq('shrimp')
    expect(logger_double).to have_received(:debug).at_least(:once)
    expect(logger_double).to have_received(:info).at_least(:once)
  end

end

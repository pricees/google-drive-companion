require_relative "test_helper.rb"

describe GoogleDriveCompanion::Socket do

  before do
    @instance = GoogleDriveCompanion::Socket.instance
  end

  it "returns socket filename" do
    ENV.delete("gdc_socket")

    @instance.socket_file.must_equal "/tmp/gdc_socket.sock"

    ENV["gdc_socket"] = "/foo"
    @instance.socket_file.must_equal "/foo"
  end

  it "returns a socket" do
    UNIXSocket.expects(:open).returns(:success!)
    @instance.socket.must_equal(:success!)
  end

  it "closes its socket" do
    @instance.expects(:socket).returns(mock(close: :success!))
    @instance.close.must_equal(:success!)
  end

  it "sends a json string to the socket" do
    ary = %w[push /path/to/file]

    socket = mock
    socket.expects(:send).with(ary.to_json, 0)
    socket.expects(:recv).with(10_000).returns(:success!)

    @instance.expects(:socket).times(2).returns(socket)
    @instance.digest(ary).must_equal(:success!)
  end
end

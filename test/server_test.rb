require_relative "test_helper.rb"

describe GoogleDriveCompanion::Server do

  before do
    @instance = GoogleDriveCompanion::Server.instance
  end

  it "returns socket filename" do
    @instance.socket_file.must_equal "/tmp/gdc_socket.sock"

    ENV["gdc_socket"] = "/foo"
    @instance.socket_file.must_equal "/foo"
  end

  it "returns pid filename" do
    @instance.pid_file.must_equal "/tmp/gdc.pid"

    ENV["gdc_pid"] = "/foo"
    @instance.pid_file.must_equal "/foo"
  end

  describe "checks if the server is running" do

    it "may be running because of the unix socket file" do
      @instance.expects(:socket_file).times(2).returns(:foo)
      @instance.expects(:pid_file).returns(:bar)

      File.expects(:exists?).with(:foo).returns(true)
      File.expects(:exists?).with(:bar).returns(false)

      @instance.expects(:exit).with(1)
      refute @instance.check_if_running!
    end

    it "may be running because of the pidfile" do
      @instance.expects(:socket_file).returns(:foo)
      @instance.expects(:pid_file).times(2).returns(:bar)

      File.expects(:exists?).with(:foo).returns(false)
      File.expects(:exists?).with(:bar).returns(true)
      File.expects(:read).with(:bar)

      @instance.expects(:exit).with(1)
      refute @instance.check_if_running!
    end

    it "isn't running" do
      @instance.expects(:socket_file).returns(:foo)
      @instance.expects(:pid_file).returns(:bar)

      File.expects(:exists?).with(:foo).returns(false)
      File.expects(:exists?).with(:bar).returns(false)

      @instance.expects(:exit).times(0)
      refute @instance.check_if_running!
    end
  end

  it "grabs a new unix socket it appropriate" do
    @instance.expects(:check_if_running!)
    @instance.expects(:write)
    @instance.expects(:socket_file).returns(:socket!)
    UNIXServer.expects(:new).with(:socket!).returns(:success!)

    @instance.server.must_equal(:success!)
  end

  it "closes its socket" do
    @instance.expects(:server).returns(mock(close: :success!))
    @instance.close.must_equal(:success!)
  end

  it "kills the server" do
    @instance.expects(:close)
    @instance.expects(:socket_file).times(2).returns(:yar!)
    @instance.expects(:pid_file).times(2).returns(:she_blows!)

    File.expects(:exists?).with(:yar!).returns(true)
    File.expects(:exists?).with(:she_blows!).returns(true)
    FileUtils.expects(:rm).times(2)
    Process.expects(:kill)

    @instance.close!
  end

  describe "runs the server" do
      it "as a daemon process" do
      @instance.expects(:server)
      Process.expects(:daemon).times(1)
      @instance.expects(:msg_pump).returns []
      @instance.run!
    end

    it "in the foreground" do
      @instance.expects(:server)
      Process.expects(:daemon).times(0)
      @instance.expects(:msg_pump).returns []
      @instance.run! :foo!
    end
  end
end

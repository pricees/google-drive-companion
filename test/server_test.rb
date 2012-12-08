require_relative "test_helper.rb"

describe GoogleDriveCompanion::Server do


  it "has a session" do
    GoogleDriveCompanion::Server.instance.session.wont_be :nil?
  end

  it "is singleton" do
    cl  = GoogleDriveCompanion::Server.instance
    3.times do
      cl.must_equal(GoogleDriveCompanion::Server.instance)
    end
  end

  it "starts a server" do
    klass = GoogleDriveCompanion::Server.instance

    refute File.exist?(klass.socket_file)
    p klass.server

    klass.server.wont_be :nil?
    assert File.exist?(klass.socket_file)

    klass.close
    refute File.exist?(klass.socket_file)
  end
end

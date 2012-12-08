require_relative "test_helper.rb"

describe GoogleDriveCompanion::Session do

  before do
    @module = GoogleDriveCompanion::Session
  end

  describe "has a config" do

    it "gets from a file" do
    end

    it "gets from env" do
    end
  end

  it "has a session" do
    @module.session.wont_be :nil?
  end

  it "sends methods" do
    ary = %w[mv bar baz]
    @module.expects(:send).with(:mv, %w[bar baz])
    @module.send_protected(ary)
  end

  it "handles message" do
    hsh = { "foo" => "bar" }
    @module.expects(:send_protected).with(hsh)
    @module.handle_msg(hsh.to_json)
  end

  describe "handles files" do

    it "seperates files by separator" do
      exp = %w(path to file.txt)
      res = @module.split_file("path/to/file.txt")
      res.must_equal(exp)

      res = @module.split_file("/path/to/file.txt")
      res.must_equal(exp)

      res = @module.split_file("/path/to/file.txt////")
      res.must_equal(exp)

      res = @module.split_file("-path-to-file.txt----", "-")
      res.must_equal(exp)
    end
  end

  describe "collections" do

    it "traverses a full collection tree" do
      root = mock
      foo  = mock
      bar  = mock
      root.expects(:subcollection_by_title).with("foo").returns(foo)
      foo.expects(:subcollection_by_title).with("bar").returns(bar)
      bar.expects(:subcollection_by_title).with("baz").returns(:success!)
      @module.expects(:root).returns(root)
      @module.traverse(%w(foo bar baz)).must_equal(:success!)
    end

    it "stops at leaf" do
      root = mock
      foo  = mock
      bar  = mock
      root.expects(:subcollection_by_title).with("foo").returns(foo)
      foo.expects(:subcollection_by_title).with("bar").returns(nil)
      @module.expects(:root).returns(root)
      @module.traverse(%w(foo bar baz)).must_equal(foo)
    end

    it "traverses a known collection tree" do
      root = mock
      foo  = mock
      bar  = mock
      root.expects(:subcollection_by_title).with("foo").returns(foo)
      foo.expects(:subcollection_by_title).with("bar").returns(nil)
      foo.expects(:create_subcollection).with("bar").returns(:success!)

      @module.expects(:root).returns(root)
      @module.traverse(%w(foo bar), :force).must_equal(:success!)
    end
  end

  it "gets the root 'directory' of the gdrive" do

    @module.expects(:session).returns(mock(root_collection: :success!))
    @module.root.must_equal :success!
  end


  describe "handles files on gdrive" do

    it "pushes a file" do
      m = mock
      m.expects(:upload_from_file).with("baz.rb", "baz.rb")
      @module.expects(:session).returns(m)

      ary = %w(baz.rb)
      @module.push(ary.join("/"))
    end

    it "pushes a file with collection" do
      m = mock
      m.expects(:upload_from_file).with("test.rb", "test.rb").returns(:remote_file)
      @module.expects(:session).returns(m)

      ary = %w(foo bar test.rb)
      col = mock
      col.expects(:add).with(:remote_file)
      @module.expects(:traverse).with(["baz"], :force).returns(col)
      @module.expects(:root).returns(mock(:remove))
      @module.push(ary.join("/"), "baz/test.rb", :force).must_equal :remote_file
    end

  end

  describe "downloading files" do
    it "pulls file to local file" do
      m = mock
      m.expects(:download_to_file).with("/tmp/out")
      @module.expects(:traverse).with(%w(foo bar baz.txt)).returns(m)
      @module.pull("foo/bar/baz.txt", "/tmp/out")
    end

    it "pulls file to local defaults" do
      m = mock
      m.expects(:download_to_file).with("baz.txt")
      @module.expects(:traverse).with(%w(foo bar baz.txt)).returns(m)
      @module.pull("foo/bar/baz.txt")
    end
  end

  it "deletes files" do
    path = "/path/to/txt"

    m = mock
    m.expects(:delete).with(:blah).returns(:blah)

    @module.expects(:traverse).with(%w[path to txt]).returns(m)

    @module.del(path, :blah).must_equal(:blah)
  end

  it "moves files" do
    old_path = "/old/path/to/txt"
    new_path = "/new/path/txt"

    m = mock
    m.expects(:subcollection_by_title).with("txt").returns(:football)
    m.expects(:remove).with(:football)

    n = mock
    n.expects(:add).with(:football).returns(:success)

    @module.expects(:traverse).with(%w[old path to]).returns(m)
    @module.expects(:traverse).with(%w[new path txt], true).returns(n)

    @module.mv(old_path, new_path).must_be :nil?
  end
end

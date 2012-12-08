module GoogleDriveCompanion

  module Session
    extend self

    # Quick n' dirty, get authentication crediables from ~/.google_drive/conf.yaml
    #
    # ~/.google_drive/conf.yaml:
    #
    # username: AzureDiamond@gmail.com
    # password: hunter2
    #
    # OR
    #
    # username=AzureDiamond@gmail.com password=hunter2 [cmd] [arg1, ... ]
    #
    def configs
      @configs ||= begin
                    fn       = File.join(Dir.home, ".google_drive", "conf.yaml")
                    configs  = File.exists?(fn) ? YAML::load(File.open(fn)) : ENV
                  end
    end

    # Public: Split filename into array by separator
    #
    # name - Name of file
    # sep  - Seperator (def. system separator)
    #
    # Examples
    #
    #   split_file("/path/to/file.txt")
    #   # => ["path", "to", "file.txt")
    #
    # split_file("-path-to-file.txt----", "-")
    # res.must_equal(exp)
    #
    # Returns array
    def split_file(name = "", sep = File::SEPARATOR)
      name.gsub(/^#{sep}+/, '').split(sep)
    end

    # Public: Return the top level folder of the accounts google drive
    #
    # Returns GoogleDrive::Collection
    def root
      session.root_collection
    end

    PROTECTED_METHODS = %w[push pull mv del]
    def send_protected(ary)
      if PROTECTED_METHODS.include?(ary.first)
        send(ary.shift.to_sym, ary)
      end
    end

    # Public: Takes an array of names of gdrive folders and traverss them.  If name is erroneous, it stops at last leaf; if forced, creates the subcollection
    #
    # Examples
    #
    #   traverse(["foo", "bar"])
    #   # => <collection "bar">
    #
    #   traverse(["foo", "bar", "baz"]) NOTE: bar doesn't exist
    #   # => <collection "foo">
    #
    #   traverse(["foo", "bar", "baz"], :force) NOTE: bar doesn't exist
    #   # => <collection "baz">
    #
    # Returns a GoogleDrive::Collection
    def traverse(collections, force = false)
      node = root
      collections.each do |subcollection|
        new_node = node.subcollection_by_title(subcollection)

        if new_node
          node = new_node
        elsif force
          node = node.create_subcollection(subcollection)
        else
          break
        end
      end

      node
    end

    # Public: Get a file from Google Drive
    #
    # ary - Array of collections, last element is title of file
    #
    # Example
    #
    #   get_file(["foo", "bar", "faz.rb"])
    #   # => <GoogleDrive::File faz.rb>
    #
    #  Returns a GoogleDrive::File
    def get_file(ary)
      title = ary.pop
      traverse(ary).
        files({ "title" => title, "title-exact" => "true" })[0]
    end

    # Public: Move file from one remote location to another
    #
    # src   - Source remote path to file
    # dest  - Destination remote path for file
    # force - Make destination folder path if not already (def. true)
    # Examples
    #
    #   mv("/old/path/to/file.txt", "/new/path/")
    #   # => mil;
    #
    # Raise RuntimeError is remote file doesn't exist
    # Returns nil
    def mv(src, dest, force = true)
      src_ary    = split_file(src)
      src_node   = traverse(src_ary[0...-1])
      file       = get_file(src_ary)

      if file
        traverse(split_file(dest), force).add(file)
        src_node.remove(file)
      else
        raise "Remote file: #{file} doesn't exist yo!"
      end

      nil
    end


    # Public: Uploads local file to remote local
    #
    # remote_file - Remote file path, File::SEPARATOR delimited
    # local_file  - Local file path, File::SEPARATOR delimited
    #
    # Examples
    #
    #   push("/tmp/text.txt")
    #   # => [ remote file /tmp/text.txt ]
    #
    #   push("/tmp/text.txt", "/remote/path/to/text.txt")
    #   # => [ remote file /remote/path/to/text.txt ]
    #
    # Returns GoogleDrive::File
    def push(local_file, remote_file = nil, force = true)

      remote_file ||= local_file
      ary           = split_file(remote_file)
      remote_fn     = ary.pop
      file          = session.upload_from_file(local_file, remote_fn)

      unless ary.empty?
        traverse(ary, force).add(file)
        root.remove(file)
      end
      file
    end

    # Public: Downloads remote file
    #
    # remote_file - Remote file path, File::SEPARATOR delimited
    # local_file  - Local file path, File::SEPARATOR delimited
    #
    # Examples
    #
    #   pull("/remote/path/to/text.txt", "/tmp/text.txt")
    #   # => [ file /tmp/text.txt ]
    #
    # Returns an integer
    def pull(remote_file, local_file = nil)

      remote_ary   = split_file(remote_file)
      local_file ||= remote_ary.last

      get_file(remote_ary).download_to_file(local_file)
    end

    # Public: Deletes remote folder
    #
    # file    - Remote file path, File::SEPARATOR delimited
    # permanent - Delete permantantly? (or just put in trash) (def. false)
    #
    # Returns boolean
    def del(file, permanently = false)
      get_file(split_file(file)).delete(permanently)
      permanently
    end

    def handle_msg(cmd)
      send_protected(JSON.parse(cmd)) || "bad command!"
    end

    def session
      @session = GoogleDrive.login(configs["username"], configs["password"])
    end
  end
end

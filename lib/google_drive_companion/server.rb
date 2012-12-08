# This module sets up a unix socket daemon process to listen out for commands
module GoogleDriveCompanion
  class Server
    include Singleton

    def session
      load "./lib/google_drive_companion/session.rb"
      GoogleDriveCompanion::Session
    end

    def socket_file
      ENV["gdc_socket"] || "/tmp/gdc_socket.sock"
    end

    def pid_file
      ENV["gdcompanion_pid"] || "/tmp/gdcompanion.pid"
    end

    def check_if_running!
      if File.exists?(socket_file)
        puts "Socket file #{socket_file} in use"
        leave = true
      end
      if File.exists?(pid_file)
        pid = File.read(pid_file)
        puts "Server may be running on #{pid}\n**************\n"
        leave = true
      end
      leave && exit(1)
    end

    def server
      @server ||= begin
                    check_if_running!
                    write(Process.pid, pid_file)
                    UNIXServer.new(socket_file)
                  end
    end

    def close
      server.close
    end

    def close!
      close
      File.exists?(socket_file) && FileUtils.rm(socket_file)
      File.exists?(pid_file) && FileUtils.rm(pid_file)
      Process.kill 9, Process.pid
    end

    # Attempts to write the pid of the forked process to the pid file.
    # Kills process if write unsuccesfull.
    def write pid, pidfile
      File.open pidfile, "w" do |f|
        f.write pid
        f.close
      end
      $stdout.puts "Daemon running with pid: #{pid}"
      rescue ::Exception => e
      raise "While writing the PID to file, unexpected #{e.class}: #{e}"
    end

    def run!(arg = nil)
      server
      Process.daemon unless arg
      msg_pump.join
    end

    def msg_pump
      Thread.new do
        loop do
          begin
            s = server.accept
            while (cmd = s.recv(1000))
              cmd = JSON.parse(cmd)
              case cmd.first
              when "close!"
                close!
              when "help!"
                s.send(File.read("lib/help.txt"), 0)
              else
                res = session.handle_msg(cmd)
                s.send("[#{cmd.first}] Success!", 0)
              end
            end
          rescue Exception => bang
            $stdout.puts "Server error: #{bang}"
          end
        end
      end
    end
  end
end

# Class: The class connects to the UNIX socket and pushes the command line as quickly as possible
#
# NOTE: I didn't comment this section, because the code is so amazing, sometimes I just cry looking at it.
#
# Oops there it goes, a tear drop right in my Portillo's Italian Sausage.
module GoogleDriveCompanion
  class Socket
    include Singleton

    def socket_file
      ENV["gdc_socket"] || File.join("", "tmp", "gdc_socket.sock")
    end

    def socket
      @socket ||= UNIXSocket.open(socket_file)
    end

    def close
      socket.close
    end

    def digest(msg)
      socket.send(msg.to_json, 0)
      socket.recv(10_000)
    end
  end
end

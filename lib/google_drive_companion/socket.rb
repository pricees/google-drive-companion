module GoogleDriveCompanion
  class Socket
    include Singleton

    def socket_file
      ENV["gdc_socket"] || "/tmp/gdc_socket.sock"
    end

    def socket
      @socket ||= UNIXSocket.open(socket_file)
    end

    def close
      socket.close
    end

    def digest(msg)
      socket.send(msg.to_json, 0)
      socket.recv(255)
    end
  end
end

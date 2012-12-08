# GoogleDriveCompanion

I was playing with the "google-drive-ruby" gem and thought it was awesome.

I don't like leaving the terminal, so I thought, meh, I am going to write a gem that allows me to push from the command line.

Then, I figured: "Yo!"  The handshake takes to long, so why not set of a unix server socket to run as a daemon, listening for my google drive commands so that it will go faster.

Sweetness!

## Installation

Add this line to your application's Gemfile:

    gem 'google_drive_companion'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google_drive_companion

## Usage

Get help

    gdrive help

Start the server using environment variables

    username=AzureDiamond@gmail.com password=hunter2 gdrive start

Or create a file in your ~/.google_drive/conf.yaml:

    username: AzureDiamond@gmail.com
    password: hunter2

Toggle the foreground/daemon flag when you start the server (def. as a daemon):

    gdrive start [run_in_foreground]

Upload a file:

    gdpush /path/to/file.txt

Upload a file from the current dir:

    gdpush this.txt

Upload a file from the current dir, to a remote location:

    gdpush this.txt remote/path/to/that.txt

Move a remote file to another remote folder:

    gdmv /path/to/file.txt /another/path

Download the new file:

    gdpull /another/path/file.txt

Trash the file:

    gddel /another/path/file.txt

Trash whole folders, with reckless abandon!

    gddel another

Kill the server:

    gdrive stop

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

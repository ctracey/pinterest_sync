#!/usr/bin/env ruby

require_relative '../src/board'
require_relative '../src/downloader'
require_relative '../src/pin'

def board_id
  ARGV[0]
end

def pinterest_api_token
  ARGV[1]
end

def download_folder
  ARGV[2]
end

def board_title
  ARGV[3]
end

def board
  Board.new(id: board_id, api_token: pinterest_api_token)
end

def send_notification(total_new_pins)
  `osascript -e 'display notification "Synced #{board_title} board: #{total_new_pins} new pins." with title "Pinterest Sync"'`
end

begin
  downloader = Downloader.new(board: board, download_path: download_folder)
  downloader.run
  send_notification(downloader.total_new_pins)
end

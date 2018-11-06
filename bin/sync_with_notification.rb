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

def send_notification(message)
  `osascript -e 'display notification "#{message}" with title "Pinterest Sync"'`
end

def sync_message(total_new_pins)
  "Synced #{board_title} board: #{total_new_pins} new pins."
end

begin
  downloader = Downloader.new(board: board, download_path: download_folder)
  synced = downloader.run

  if synced
    send_notification(sync_message(downloader.total_new_pins))
  else
    error_message = "ERROR: Failed to sync - #{board_title}"
    puts error_message
    send_notification(error_message)
  end
end

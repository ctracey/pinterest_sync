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

def board
  Board.new(id: board_id, api_token: pinterest_api_token)
end

begin
  downloader = Downloader.new(board: board, download_path: download_folder)
  downloader.run
end

#!/usr/bin/env ruby
# raffle_best_of_7.rb
#
# Provably fair raffle draw:
# - Entrants: 1..N
# - Winner = first number to reach 4 points (best-of-7 style)
# - RNG is seeded from an arbitrary string (e.g. block hash, random.org value)
# - Same entrants + same seed string = same result (reproducible)
#
# Usage:
#   ruby raffle_best_of_7.rb                # default 67 entrants, no explicit seed
#   ruby raffle_best_of_7.rb 67 "my seed"   # 67 entrants, seeded from "my seed"
#
# For full transparency, publish:
#   - this script
#   - the exact seed string you used
#   - the screen recording of the run

require 'cli/ui'
require 'digest'

# ---- CONFIG DEFAULTS ----
DEFAULT_ENTRANTS = 67
WIN_TARGET       = 4      # first to 4 points (best of 7)
GRAPH_LIMIT      = 5      # show top 5 numbers in the graph
SLEEP_SECONDS    = 0.4    # delay between rounds for readability

# ---- CLI ARGS ----
entrants   = (ARGV[0] || DEFAULT_ENTRANTS).to_i
seed_string = ARGV[1]     # any string; can be a block hash, random.org output, etc.

abort("Need at least 2 entrants") if entrants < 2

CLI::UI::StdoutRouter.enable

def seed_rng_from_string(str)
  # Deterministic integer seed from arbitrary string via SHA-256
  digest_hex = Digest::SHA256.hexdigest(str)
  digest_hex.to_i(16)
end

def print_vertical_graph(counts, limit:)
  return if counts.empty?

  # Sort by points desc, then by number asc; take top N
  sorted = counts.sort_by { |num, pts| [-pts, num] }.first(limit)
  max_pts = sorted.map(&:last).max || 0
  return if max_pts.zero?

  puts
  puts "Live vertical graph (top #{sorted.size} numbers):"

  # From top row (max points) down to 1
  max_pts.downto(1) do |level|
    line = sorted.map do |(_num, pts)|
      pts >= level ? " █ " : "   "
    end.join
    puts line
  end

  # Labels under bars
  labels = sorted.map { |num, _pts| num.to_s.rjust(3) }.join(" ")
  puts labels
  puts
end

CLI::UI::Frame.open("🎨 FAIR DRAW: BEST OF 7 🎨") do
  puts "Total entrants: #{entrants}"
  puts "Numbers in the draw: 1..#{entrants}"

  if seed_string && !seed_string.empty?
    seed_int = seed_rng_from_string(seed_string)
    srand(seed_int)
    puts "Seed string: #{seed_string.inspect}"
    puts "SHA256(seed_string) as integer: #{seed_int}"
    puts "Anyone can reproduce this draw with the same script, entrants, and seed string."
  else
    puts "No seed string provided. Using Ruby default RNG (not reproducibly provable)."
  end

  puts "Winner = first to #{WIN_TARGET} points (best-of-7 style)"
  puts "-" * 60

  counts = Hash.new(0)
  round  = 0
  winner = nil

  CLI::UI::Spinner.spin("Starting draw...") do |spinner|
    loop do
      round += 1
      pick = rand(1..entrants)
      counts[pick] += 1

      spinner.update_title("Round #{round}: drew ##{pick} (now #{counts[pick]} pt#{'s' if counts[pick] != 1})")

      puts "-" * 40
      puts "Round #{round}: drew ##{pick} (#{counts[pick]} pt#{'s' if counts[pick] != 1})"
      print_vertical_graph(counts, limit: GRAPH_LIMIT)

      if counts[pick] >= WIN_TARGET
        winner = pick
        spinner.update_title("Winner selected: ##{winner} (reached #{WIN_TARGET} points)")
        break
      end

      sleep SLEEP_SECONDS
    end
  end

  puts "-" * 60
  CLI::UI::Frame.open("🏆 WINNER 🏆") do
    puts "Number ##{winner} reached #{WIN_TARGET} points!"
  end

  puts "-" * 60
  CLI::UI::Frame.open("📊 Final tally (only numbers drawn)") do
    counts.keys.sort.each do |num|
      pts = counts[num]
      puts "##{num}: #{pts} point#{'s' if pts != 1}"
    end
  end
end

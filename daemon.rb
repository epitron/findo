#!/usr/bin/env ruby

require 'epitools'
require 'rb-inotify'
require_relative "file_index"

notifier = INotify::Notifier.new
$index   = FileIndex.new(log: true)
$queue   = Set.new

def process_queue
  # puts "<8>* <11>Processing queue".colorize
  $queue.each do |path|
    puts "<8>* <14>Indexing: <3>#{path}".colorize
    $index.add Path[path]
  end
  # puts "<8>  |_ <14>Done!".colorize

  $queue.clear
end

# :close_write, :modify, :attrib, :move, :delete
notifier.watch(ARGV.first, :close_write, :attrib, :move) do |event|
  puts "<14>#{event.absolute_name}".colorize
  $queue << event.absolute_name
end


loop do
  # only process new files if nothing has happened for 5 seconds
  if IO.select([notifier.to_io], [], [], 5) 
    puts "notified"
    notifier.process
  end

  process_queue
end

# notifier.run

# ## Flags

# `:access` : A file is accessed (that is, read).
# `:attrib` : A file's metadata is changed (e.g. permissions, timestamps, etc).
# `:close_write` : A file that was opened for writing is closed.
# `:close_nowrite` : A file that was not opened for writing is closed.
# `:modify` : A file is modified.
# `:open` : A file is opened.

# ### Directory-Specific Flags

# These flags only apply when a directory is being watched.

# `:moved_from` : A file is moved out of the watched directory.
# `:moved_to` : A file is moved into the watched directory.
# `:create` : A file is created in the watched directory.
# `:delete` : A file is deleted in the watched directory.
# `:delete_self` : The watched file or directory itself is deleted.
# `:move_self` : The watched file or directory itself is moved.

# ### Helper Flags

# These flags are just combinations of the flags above.

# `:close` : Either `:close_write` or `:close_nowrite` is activated.
# `:move` : Either `:moved_from` or `:moved_to` is activated.
# `:all_events` : Any event above is activated.

# ### Options Flags

# These flags don't actually specify events.
# Instead, they specify options for the watcher.

# `:onlydir` : Only watch the path if it's a directory.
# `:dont_follow` : Don't follow symlinks.
# `:mask_add` : Add these flags to the pre-existing flags for this path.
# `:oneshot` : Only send the event once, then shut down the watcher.
# `:recursive`
#   Recursively watch any subdirectories that are created.
#   Note that this is a feature of rb-inotify,
#   rather than of inotify itself, which can only watch one level of a directory.
#   This means that the {Event#name} field
#   will contain only the basename of the modified file.
#   When using `:recursive`, {Event#absolute_name} should always be used.

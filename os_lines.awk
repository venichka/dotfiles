# Per-OS lines in a config file shared by macOS and Linux. The sync scripts use it for
# rio/config.toml, because Rio can't set font size, line-height or NativeTab per OS itself.
#
# The repo keeps the Linux form. A line that differs on macOS carries its macOS version
# after a "# macos:" tag, and a macOS-only line is commented out with "# macos:":
#     size = 16                # macos: size = 12
#     # macos: mode = "NativeTab"
# Rendered for macOS, the two sides swap, so the file still says what Linux uses:
#     size = 12                # linux: size = 16
#     mode = "NativeTab"  # macos only
# Rendering for Linux turns that back into the repo form. A file already in the
# requested form passes through unchanged. Keep other comments off tagged lines.
#
# Usage: awk -v os=macos|linux -f os_lines.awk FILE

# swap(line, tag, newtag): "A<spaces><tag>B" -> "B<spaces><newtag>A", keeping the tag's column
function swap(line, tag, newtag,    i, a, b, w) {
  i = index(line, tag)
  a = substr(line, 1, i - 1)
  sub(/[ \t]+$/, "", a)
  b = substr(line, i + length(tag))
  w = i  # the tag's "#" sits at column i + 1
  if (length(b) + 1 > w) w = length(b) + 1
  return sprintf("%-" w "s", b) newtag a
}

os == "macos" && /^# macos: / { print substr($0, 10) "  # macos only"; next }
os == "macos" && index($0, " # macos: ") { print swap($0, " # macos: ", "# linux: "); next }

os == "linux" && /[ \t]# macos only[ \t]*$/ {
  line = $0
  sub(/[ \t]+# macos only[ \t]*$/, "", line)
  print "# macos: " line
  next
}
os == "linux" && index($0, " # linux: ") { print swap($0, " # linux: ", "# macos: "); next }

{ print }

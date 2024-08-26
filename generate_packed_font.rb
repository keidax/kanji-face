#!/usr/bin/env ruby

# frozen_string_literal: true

font_size = 60
font_file = '/usr/share/fonts/noto-cjk/NotoSerifCJK-Light.ttc'

CHUNK_SIZE = 64
kanji_file = ARGV[0]
kanji = []

File.open(kanji_file).each_line(chomp: true) do |line|
  next if line.start_with?('#')
  next if line.empty?

  kanji << line[0]
end

kanji.sort!

base_id = 19_968

kanji.each_slice(CHUNK_SIZE).with_index do |chunk, i|
  output = "kanji-#{i}"
  char_ids = chunk.map(&:ord)

  char_range = char_ids.join(',')

  cmd = "fontbm --font-file #{font_file} \
    --font-size #{font_size} \
    --monochrome \
    --output resources/fonts/#{output} \
    --chars #{char_range}"
  system(cmd, exception: true)

  # Use sed to translate the original Unicode ids into the packed encoding. This must be
  # done in 2 stages, to ensure ids don't get translated twice.
  sed_id_surround_cmds = char_ids.map { |id| "s/id=#{id} /id=X#{id}X /" }.join(';')
  sed_id_translate_cmds = char_ids.map.with_index { |id, j| "s/id=X#{id}X /id=#{base_id + j} /" }.join(';')

  system(
    "sed -i '#{sed_id_surround_cmds}' resources/fonts/#{output}.fnt",
    exception: true
  )
  system(
    "sed -i '#{sed_id_translate_cmds}' resources/fonts/#{output}.fnt",
    exception: true
  )

  puts %(<font id="Kanji#{i}" filename="fonts/#{output}.fnt" />)

  base_id += CHUNK_SIZE
end

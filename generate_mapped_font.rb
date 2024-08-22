#!/usr/bin/env ruby

# frozen_string_literal: true

font_size = 26
font_file = '/usr/share/fonts/noto-cjk/NotoSansCJK-DemiLight.ttc'

mapping_file = ARGV[0]
mappings = []

File.open(mapping_file).each_line(chomp: true) do |line|
  next if line.start_with?('#')
  next if line.empty?

  mappings << [line[0], line[1]]
end

mappings.sort!

output = 'status'
char_ids = mappings.map { |m| m[0].ord }

char_range = char_ids.join(',')

cmd = "fontbm --font-file #{font_file} \
    --font-size #{font_size} \
    --monochrome \
    --output resources/fonts/#{output} \
    --chars #{char_range}"
# pp cmd
system(cmd, exception: true)

sed_id_replacements = mappings.map { |(a, b)| "s/id=#{a.ord} /id=#{b.ord} /" }.join(';')

sed_cmd = "sed -i '#{sed_id_replacements}' resources/fonts/#{output}.fnt"
system(sed_cmd, exception: true)

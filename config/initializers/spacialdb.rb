if ENV['SPACIALDB_URL']

  regex = Regexp.new("(.*):\\/\\/(.*):(.*)@(.*):([\\d]{3,5})\\/(.*)")
  matchdata = regex.match(ENV['SPACIALDB_URL'])

  SpacialdbConnectionConfig = {
    :adapter => "postgresql",
    :username => matchdata[2],
    :password => matchdata[3],
    :host => matchdata[4],
    :port => Integer(matchdata[5]),
    :database => matchdata[6]
  }
else
  SpacialdbConnectionConfig = YAML.load_file("#{Rails.root.to_s}/config/spacialdb.yml")["spacialdb_#{Rails.env.to_s}"]
end

require 'rspec'

require File.join Dir.pwd, 'lib/models/shows.rb'

describe Shows do
  before(:example) do
    show_hashes = JSON.parse(File.open("test/data/shows.json").read)["shows"]
    @shows = Shows.new(show_hashes)
    @returned_show = Show.new({
      "rss" => "http://feeds.feedburner.com/linuxunvid",
      "url" => "lu",
      "title" => "Linux Unplugged",
      "aliases" => [
      	"lun",
        "lup",
      ]
    })
  end

  it 'initializes properly' do
  	expect(@shows.shows[0].rss).to eq @returned_show.rss
  	expect(@shows.shows[0].title).to eq @returned_show.title
  	expect(@shows.shows[0].url).to eq @returned_show.url
  	expect(@shows.shows[0].aliases).to match_array(@returned_show.aliases)
  end

  it 'loads shows inflight' do
  	new_show = [{
      "rss" => "las.com/las",
      "url" => "las",
      "title" => "Linux Action Show",
      "aliases" => [
      	"linuxas",
        "lashow",
      ]
    }]
    @shows.load(new_show)
    expect(@shows.shows.length).to eq 2
    expect(@shows.shows[1].class).to eq Show
    expect(@shows.shows[1]).to have_attributes(:rss => new_show[0]['rss'], :url => new_show[0]['url'], :title => new_show[0]['title'], :aliases => ["linuxas", "lashow"])
  end

  it 'matches a show using a known keyword' do
  	expect(@shows.find_show('lun').class).to eq Show
  	expect(@shows.find_show('lun').title).to eq "Linux Unplugged"
  end

  it 'does not match a show with an unknown keyword' do
  	expect(@shows.find_show('las')).to eq nil
  end

  it 'does not match a show if given an empty string' do
  	expect(@shows.find_show('')).to eq nil
  end

  it 'deletes a show' do
  	@shows.remove('lu')
  	expect(@shows.shows.length).to eq 0
  end

  it 'does not delete a show if it does not match' do
  	@shows.remove('las')
  	expect(@shows.shows.length).to eq 1
  end
end
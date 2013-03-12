# wordcount.rb
#
# Model that tracks the number of times a word appears across all shows.

require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-aggregates'
require 'stopwords'

class WordCount
  include DataMapper::Resource
  
  property :id,     Serial
  property :word,   String,   :unique => true, :required => true
  property :frequency,  Integer,  :default => 0
  
  def add_one
    self.frequency = self.frequency + 1
    self.save
  end
  
  # ------------------
  # Class Methods
  # ------------------

  def self.count_document_frequency
    puts "Starting count_document_frequency"
    
    if IdfTracker.count == 0
      suggestion_sets = Suggestion.all(:order => [:created_at.desc]).group_by_show
      IdfTracker.create( last_suggestion_time: Suggestion.last.created_at, last_suggestion_show: Suggestion.last.show )
      IdfTracker.first.update(document_count: suggestion_sets.count)
    else
      # get shows since last check - make sure that the first titles aren't from the same show as the last one counted
      from = IdfTracker.first.last_suggestion_time
      suggestion_sets = Suggestion.all(:created_at.gt => from, :order => [:created_at.desc]).group_by_show
      return if suggestion_sets.count == 0
      
      first_new_suggestion = Suggestion.first(:created_at.gt => from)
      if IdfTracker.first.last_suggestion_show == first_new_suggestion.show and
         (IdfTracker.first.last_suggestion_time - first_new_suggestion.created_at) > 0.75
        IdfTracker.first.update(document_count: IdfTracker.first.document_count + suggestion_sets.count - 1, # already counted first episode of new set
          last_suggestion_show: Suggestion.last(:created_at.gt => from).show, last_suggestion_time: Suggestion.last(:created_at.gt => from).created_at)
      else
        IdfTracker.first.update(document_count: IdfTracker.first.document_count + suggestion_sets.count,
          last_suggestion_show: Suggestion.last(:created_at.gt => from).show, last_suggestion_time: Suggestion.last(:created_at.gt => from).created_at)
      end
    end
    
    my_stop_words = Stopwords::STOP_WORDS
    my_stop_words.push("'s", "n't", "'ll", "'re", "'d", "'ve", "'m", ".", "!", "?", ",", "*", "...", "(", ")", "&", "``", "''")
    
    suggestion_sets.each do |set|
      word_list = []
      set.suggestions.each { |suggestion| word_list += tokenize(suggestion.title.downcase) }
      word_list = word_list.uniq - my_stop_words
      word_list.each { |word| WordCount.first_or_create(:word => word).add_one }
    end
  end
  
end

def tokenize(str)
  # Normalize all whitespace
  str.gsub!(/\s+/, ' ')
  
  # Fix curly quotes
  trans = { "\u2018" => "`",
    "\u2019" => "'",
    "\u201c" => "``",
    "\u201d" => "''",
  }
  trans_re = trans.keys.join('')
  str.gsub!(/([#{trans_re}])/) { " " + trans[$1] + " " }
  
  # Attempt to get correct directional quotes
  str.gsub!(/\"\b/, ' `` ')
  str.gsub!(/\b\"/, " '' ")
  str.gsub!(/\"(?=\s)/, " '' ")
  str.gsub!(/\"/, ' `` ')
  
  # Isolate all ellipses
  str.gsub!(/\.\.\./, ' ... ')
  
  # Isolate any embedded punctuation chars
  str.gsub!(/([,;:\@\#\$\%&])/, ' \1 ')
  
  # Assume sentence tokenization has been done first, so split FINAL periods only
  str.gsub!(/ ([^.]) \.  ([\]\)\}\>\"\']*) [ \t]* $ /x, '\1 .\2')

  # hHowever, we may as well split ALL question marks and exclamation points,
  # since they shouldn't have the abbrev-marker ambiguity problem
  str.gsub!(/([?!])/, ' \1 ')
  
  # parentheses, brackets, etc.
  str.gsub!(/([\]\[\(\)\{\}\<\>])/, ' \1 ')
  
  str.gsub!(/(-{2,})/, ' \1 ')
  
  # Add a space to the beginning and end of each line, to reduce
  # necessary number of regexps below
  
  str.gsub!(/$/, ' ');
  str.gsub!(/^/, ' ');
  
  # possessive or close-single-quote
  str.gsub!(/\([^\']\)\' /, '\1 \' ')
  
  # as in it's, I'm, we'd
  str.gsub!(/\'([smd]) /i, ' \'\1 ')
  
  str.gsub!(/\'(ll|re|ve) /i, ' \'\1 ')
  str.gsub!(/n\'t /i, ' n\'t ')

  str.gsub!(/ (can)(not) /i, ' \1 \2 ')
  str.gsub!(/ (d\')(ye) /i, ' \1 \2 ')
  str.gsub!(/ (gim)(me) /i, ' \1 \2 ')
  str.gsub!(/ (gon)(na) /i, ' \1 \2 ')
  str.gsub!(/ (got)(ta) /i, ' \1 \2 ')
  str.gsub!(/ (lem)(me) /i, ' \1 \2 ')
  str.gsub!(/ (more)(\'n) /i, ' \1 \2 ')
  str.gsub!(/ (\'t)(is|was) /i, ' \1 \2 ')
  str.gsub!(/ (wan)(na) /i, ' \1 \2 ')
  
  str.split(' ')
end
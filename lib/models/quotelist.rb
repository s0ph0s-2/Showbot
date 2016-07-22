class QuoteList
  def initialize(config)
    unless config[:quotes_file].nil?
      @quotes_path = File.join File.dirname(__FILE__), "../../#{config[:quotes_file]}"
      @quotes = YAML.load_file @quotes_path
      @can_save = true
    else
      warn "Quotes file was nil. QUOTE CHANGES WILL NOT BE SAVED!"
      @can_save = false
    end
  end

  def quote_for(name)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:quotes].sample
  end

  def add(name, quote)
    name.downcase!
    @quotes[name] ||= {aliases:[], quotes:[]}
    if @quotes[name][:quotes].select {|q| q.downcase == quote.downcase} == []
      @quotes[name][:quotes] << quote
      save_to_disk
    else
      ''
    end
  end

  def del(name, quote)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:quotes].delete(quote)
    @quotes.delete(canonical_name) if @quotes[canonical_name][:quotes].length == 0
    save_to_disk
  end

  def add_alias(name, a)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:aliases] << a
    save_to_disk
  end

  def del_alias(name, a)
    canonical_name = canonicalize name
    return '' if !canonical_name
    @quotes[canonical_name][:aliases].delete(a)
    save_to_disk
  end

  private

  def canonicalize(name)
    name.downcase!

    @quotes.select do |canonical, value|
      match_canonical?(canonical, name) || in_aliases?(value[:aliases], name)
    end.keys.first
  end

  def match_canonical?(canonical, name)
    canonical.downcase == name
  end

  def in_aliases?(aliases, name)
    Array(aliases).map(&:downcase).any? do |element|
      element.downcase == name
    end
  end

  def save_to_disk
    File.open(@quotes_path, "w") {|file| file.write(@quotes.to_yaml)} if @can_save
  end
end

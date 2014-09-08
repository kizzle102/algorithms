require_relative 'predictor'

class ComplexPredictor < Predictor
  # Public: Trains the predictor on books in our dataset. This method is called
  # before the predict() method is called.
  #
  # Returns nothing.
  def train!
    @data = {}

    @all_books.each do |category, books|
      @data[category] = []
      books.each do |filename, tokens|
        good_token_count(tokens[300..-300]).each do |x|
          @data[category] << x
        end
      end
    end
  end

  def good_token_count(tokens, num=70)
    @top_words = []
    result = tokens.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1}

    cutoff_val = result.values.sort[-1 * num]
    cutoff_words = result.select{|k,v| v >= cutoff_val}
    cutoff_words.each do |word, count|
      @top_words << word
    end

    #result.sort_by {|word, counts| counts.reverse}

    @top_words
  end

  # Public: Predicts category.
  #
  # tokens - A list of tokens (words).
  #
  # Returns a category.
  def predict(tokens)
    start = tokens.length/4
    predict_common_words = good_token_count(tokens[start..(start*2)])

    predicted_category = nil
    counter = 0

    @data.each do |category, cat_data|
      matching_words = (predict_common_words & cat_data)
      max_matches = matching_words.size

      if max_matches > counter
        counter = max_matches
        predicted_category = category 
      end
    end

    predicted_category

  end
end




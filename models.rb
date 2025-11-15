class Questionnaire
  attr_accessor :id, :title, :questions
  def initialize(id, title)
    @id = id
    @title = title
    @longest_id = 0
  end

  def add_questions(questions_data)
    @questions ||= []
    questions_data.each do |key, value|
      question = nil
      if value["type"] == "text"
        question = TextQuestion.new(key, value)
      elsif value["type"] == "checkbox"
        question = CheckboxQuestion.new(key, value)
      elsif value["type"] == "radio"
        question = RadioQuestion.new(key, value)
      elsif value["type"] == "dropdown"
        question = DropdownQuestion.new(key, value)
      elsif value["type"] == "boolean"
        question = BooleanQuestion.new(key, value)
      end

      if question
        @longest_id = question.id.length if question.id && question.id.length > @longest_id
        @questions.append(question)
      end
    end
  end

  def print(user_response)
    puts @title
    @questions.each do |question|
      if user_response.key?(question.id)
        diff = @longest_id - question.id.length
        space = " " * diff
        label = question.id.gsub('_', ' ').split.map(&:capitalize).join(' ')
        puts "#{label}: #{space}\e[32m#{user_response[question.id]}\e[0m"
      end
    end
  end
end

class Question
  attr_accessor :id, :label, :visible
  def initialize(id, data)
    @id = id
    @label = data["label"] ? data["label"] : nil
    @visible = data["visible"] ? data["visible"] : nil
  end

  def valid_response(response)
    true
  end

  def instructions
    ""
  end
end

class QuestionWithOptions < Question
  attr_accessor :options
  def initialize(id, data)
    super
    @options ||= data["options"]
  end
end

class TextQuestion < Question
  def initialize(id, data)
    @min_length = data["min_length"] ? data["min_length"] : nil
    @max_length = data["max_length"] ? data["max_length"] : nil
    super
  end

  def valid_response(response)
    return false if @min_length && response.length < @min_length
    return false if @max_length && response.length > @max_length
    true
  end

  def instructions
    instructions = @min_length || @max_length ? "You can enter " : ""
    instructions += "at least <#{@min_length}> characters" if @min_length
    instructions += " and " if @min_length && @max_length
    instructions += "at most <#{@max_length}> characters" if @max_length
    instructions
  end
end

class CheckboxQuestion < QuestionWithOptions
end

class RadioQuestion < QuestionWithOptions
end

class DropdownQuestion < QuestionWithOptions
end

class BooleanQuestion < Question
end

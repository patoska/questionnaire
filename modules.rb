require_relative 'models'

module QuestionnaireFiles
  require 'yaml'

  class FilesInterface
    def load(files)
      questionnaires = []
      files.each do |filename|
        questionnaire = YAML.load_file(filename)
        q = Questionnaire.new(questionnaire["id"], questionnaire["title"])
        q.add_questions(questionnaire["questions"])
        questionnaires.append(q)
      end
      return questionnaires
    end

    def save(filename, responses)
      File.write(filename, responses.to_yaml)
    end
  end

  def self.load(files)
    l = FilesInterface.new
    return l.load(files)
  end

  def self.save(filename, responses)
    l = FilesInterface.new
    l.save(filename, responses)
  end
end

module QuestionnaireResponder
  require 'tty-prompt'

  class Responder
    def initialize(questionnaires)
      @questionnaires = questionnaires
    end

    def respond
      responses = {}
      @questionnaires.each do |questionnaire|
        responses[questionnaire.id] = {}
        questionnaire.questions.each do |question|
          next unless is_visible(responses[questionnaire.id], question)
          response = ""
          loop do
            response = ask_question(question)
            break if !response.nil? && question.valid_response(response)
            puts "Invalid response"
          end
          responses[questionnaire.id][question.id] = response
        end
      end
      return responses
    end

    private

    def is_visible(responses, question)
      visible = true
      unless question.visible.nil?
        question.visible.each do |key, condition|
          if condition.key?("value")
            if condition['operator'] == "and"
              visible = visible && condition['value'] == responses[key]
            elsif condition['operator'] == "or"
              visible = visible || condition['value'] == responses[key]
            else
              visible = condition['value'] != responses[key]
            end
          else
            if condition['operator'] == "and"
              visible = visible && responses[key]
            elsif condition['operator'] == "or"
              visible = visible || responses[key]
            else
              visible = !responses[key]
            end
          end
        end
      end
      return visible
    end

    def ask_question(question)
      prompt = TTY::Prompt.new
      label = "#{question.label} #{question.instructions}"
      if question.class == TextQuestion
        return prompt.ask(label)
      elsif question.class == CheckboxQuestion
        return prompt.multi_select(label, question.options.invert)
      elsif question.class == RadioQuestion || question.class == DropdownQuestion
        return prompt.select(label, question.options.invert)
      elsif question.class == BooleanQuestion
        choices = { 'Yes' => true, 'No'  => false }
        return prompt.select(label, choices)
      end
    end
  end

  def self.respond(questionnaires)
    r = Responder.new(questionnaires)
    return r.respond
  end
end

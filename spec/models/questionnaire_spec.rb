require "rspec"
require_relative "../../models"

RSpec.describe Questionnaire do
  let(:data) do
    {
      "q1" => { "type" => "text", "label" => "Age?", "min_length" => 2 },
      "q2" => { "type" => "checkbox", "label" => "Fruits", "options" => { "Apple" => "a" } },
      "q3" => { "type" => "radio", "label" => "Gender", "options" => { "Male" => "m" } },
      "q4" => { "type" => "dropdown", "label" => "City", "options" => { "NY" => "ny" } },
      "q5" => { "type" => "boolean", "label" => "Accept?" }
    }
  end

  subject(:questionnaire) { described_class.new("id1", "Test Title") }

  describe "#add_questions" do
    it "creates the correct question types" do
      questionnaire.add_questions(data)

      expect(questionnaire.questions.size).to eq(5)

      expect(questionnaire.questions[0]).to be_a(TextQuestion)
      expect(questionnaire.questions[1]).to be_a(CheckboxQuestion)
      expect(questionnaire.questions[2]).to be_a(RadioQuestion)
      expect(questionnaire.questions[3]).to be_a(DropdownQuestion)
      expect(questionnaire.questions[4]).to be_a(BooleanQuestion)
    end

    it "tracks longest id" do
      questionnaire.add_questions(data)
      expect(questionnaire.instance_variable_get(:@longest_id)).to eq("q1".length)
    end
  end

  describe "#print" do
    it "prints formatted answers with green text" do
      questionnaire.add_questions(data)
        responses = { "q1" => "25" }

      expect { questionnaire.print(responses) }
        .to output(/Test Title\nQ1:\s+\e\[32m25\e\[0m/).to_stdout
    end
  end
end

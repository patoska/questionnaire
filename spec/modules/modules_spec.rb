require "rspec"
require "yaml"
require_relative "../../models"
require_relative "../../modules"

RSpec.describe QuestionnaireFiles do
  let(:yaml_content1) do
    {
      "id" => "q1",
      "title" => "First",
      "questions" => {
        "a" => { "label" => "Age", "type" => "text", "min_length" => 2 }
      }
    }
  end

  before do
    allow(YAML).to receive(:load_file).with("file1.yml").and_return(yaml_content1)
  end

  describe ".load" do
    it "creates Questionnaire with real questions" do
      results = QuestionnaireFiles.load(["file1.yml"])

      expect(results.length).to eq(1)

      q = results.first
      expect(q).to be_a(Questionnaire)
      expect(q.questions.first).to be_a(TextQuestion)
    end
  end

  describe ".save" do
    it "writes YAML file" do
      responses = { "q1" => { "a" => "hello" } }

      expect(File).to receive(:write).with("output.yml", responses.to_yaml)

      QuestionnaireFiles.save("output.yml", responses)
    end
  end
end

RSpec.describe QuestionnaireResponder do
  let(:questionnaire) do
    Questionnaire.new("q1", "Test").tap do |q|
      q.add_questions({
        "age" => { "type" => "text", "label" => "Age", "min_length" => 1 }
      })
    end
  end

  let(:prompt_double) { instance_double(TTY::Prompt) }

  before do
    allow(TTY::Prompt).to receive(:new).and_return(prompt_double)
    allow(prompt_double).to receive(:ask).and_return("33")
  end

  describe ".respond" do
    it "collects text responses" do
      responses = QuestionnaireResponder.respond([questionnaire])

      expect(responses).to eq({ "q1" => { "age" => "33" } })
    end
  end

  describe QuestionnaireResponder::Responder do
    let(:responder) { described_class.new([questionnaire]) }

    describe "#is_visible" do
      it "returns true when visible=nil" do
        question = questionnaire.questions.first
        expect(responder.send(:is_visible, {}, question)).to eq(true)
      end

      it "evaluates value-based rule" do
        q = questionnaire.questions.first
        q.visible = { "age" => { "value" => "33", "operator" => "and" } }

        expect(responder.send(:is_visible, { "age" => "33" }, q)).to eq(true)
      end
    end

    describe "#ask_question" do
      it "prompts text" do
        answer = responder.send(:ask_question, questionnaire.questions.first)

        expect(prompt_double).to have_received(:ask)
        expect(answer).to eq("33")
      end
    end
  end
end

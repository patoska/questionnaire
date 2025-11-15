require "rspec"
require_relative "../../models"

RSpec.describe Question do
  let(:question) { described_class.new("q1", { "label" => "Name?" }) }

  it "sets id and label" do
    expect(question.id).to eq("q1")
    expect(question.label).to eq("Name?")
  end

  it "allows any response by default" do
    expect(question.valid_response("anything")).to eq(true)
  end

  it "instructions defaults to empty" do
    expect(question.instructions).to eq("")
  end
end

RSpec.describe TextQuestion do
  describe "#valid_response" do
    it "validates min_length" do
      q = TextQuestion.new("q1", { "min_length" => 3 })
      expect(q.valid_response("hi")).to eq(false)
      expect(q.valid_response("hey")).to eq(true)
    end

    it "validates max_length" do
      q = TextQuestion.new("q1", { "max_length" => 4 })
      expect(q.valid_response("hello")).to eq(false)
      expect(q.valid_response("hey")).to eq(true)
    end

    it "validates both" do
      q = TextQuestion.new("q1", { "min_length" => 2, "max_length" => 4 })
      expect(q.valid_response("a")).to eq(false)
      expect(q.valid_response("abc")).to eq(true)
      expect(q.valid_response("abcde")).to eq(false)
    end
  end

  describe "#instructions" do
    it "returns instructions for min/max" do
      q = TextQuestion.new("q1", { "min_length" => 2, "max_length" => 5 })
      expect(q.instructions).to eq("You can enter at least <2> characters and at most <5> characters")
    end
  end
end

RSpec.describe QuestionWithOptions do
  it "stores options" do
    q = QuestionWithOptions.new("q1", { "options" => { "Yes" => "y" } })
    expect(q.options).to eq({ "Yes" => "y" })
  end
end

RSpec.describe CheckboxQuestion do
  it "inherits from QuestionWithOptions" do
    q = CheckboxQuestion.new("q1", { "options" => { A: 1 } })
    expect(q).to be_a(QuestionWithOptions)
  end
end

RSpec.describe RadioQuestion do
  it "inherits from QuestionWithOptions" do
    q = RadioQuestion.new("q1", { "options" => { A: 1 } })
    expect(q).to be_a(QuestionWithOptions)
  end
end

RSpec.describe DropdownQuestion do
  it "inherits from QuestionWithOptions" do
    q = DropdownQuestion.new("q1", { "options" => { A: 1 } })
    expect(q).to be_a(QuestionWithOptions)
  end
end

RSpec.describe BooleanQuestion do
  it "inherits from Question" do
    q = BooleanQuestion.new("q1", {})
    expect(q).to be_a(Question)
  end
end

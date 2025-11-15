require_relative 'modules'

current_arg = nil
config_args = []
responses_filename = "responses.yml"
questionnaire_filenames = []

ARGV.each_with_index do |arg, index|
  if arg == "--config" || arg == "--responses"
    current_arg = arg
  elsif current_arg == "--config"
    config_args.append(arg)
  elsif current_arg == "--responses"
    responses_filename = arg
    current_arg = nil
  end
end

config_args.each do |filename|
  questionnaire_filenames.concat(filename.split(','))
end

questionnaires = QuestionnaireFiles.load(questionnaire_filenames)
responses = QuestionnaireResponder.respond(questionnaires)

QuestionnaireFiles.save(responses_filename, responses)

puts "Printing responses:"
questionnaires.each do |q|
  puts ""
  q.print(responses[q.id])
end

# Questionnaire

This implementation uses 2 gems; if you don't have them installed, use:
```
gem install tty-prompt rspec
```

To run the specs use:
```
rspec spec/models/questionnaire_spec.rb spec/models/questions_spec.rb spec/modules/modules_spec.rb
```

You can run the script as follows:
```
ruby questionnaire.rb --config personal_information.yaml,about_the_situation.yaml --responses user_response.yaml
```

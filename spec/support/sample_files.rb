def sample_questions
  File.open('spec/fixtures/questions.xml')
end

def import_questions_for_today
  File.open('spec/fixtures/import_questions_for_today.xml')
end


def import_questions_for_today_with_changes
  File.open('spec/fixtures/import_questions_for_today_with_changes.xml')
end




def sample_questions_by_uin
  File.open('spec/fixtures/questions_by_uin.xml')
end
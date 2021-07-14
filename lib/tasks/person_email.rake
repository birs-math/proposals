namespace :birs do
  desc "Remove duplicate email record"
  task remove_duplicate_record: :environment do
    person = Person.group(:email).having('count("email") > 1').count(:email)
    person.each do |key, value|
      duplicates = Person.where(email: key)[1..value-1]
      puts "#{key} = #{duplicates.count}"
      duplicates.each(&:destroy)
    end
  end
end

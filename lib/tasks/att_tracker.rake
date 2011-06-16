namespace :att_tracker do
  desc "Reset the Tracker application environment   RAILS_ENV=production"
  task :reset => :environment do
    Rake::Task["db:migrate:reset"].invoke
    Rake::Task["db:fixtures:load"].invoke
  end
end
require_relative 'application'

Rails.application.load_tasks

module Clockwork
  configure do |config|
    config[:thread] = true
    config[:tz] = 'Europe/Bratislava'
  end

  handler do |job|
    Rake::Task[job].reenable
    Rake::Task[job].invoke
  end

  every(1.day, 'uvobot:run', at: '15:00')
end
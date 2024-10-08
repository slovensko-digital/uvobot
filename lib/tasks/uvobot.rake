namespace :uvobot do
  desc "Run uvobot"
  task run: :environment do
    require 'date'
    require_relative '../uvobot'

    notifiers = []

    if ENV['UVOBOT_SLACK_WEBHOOK']
      ENV.fetch('UVOBOT_SLACK_WEBHOOK').split(',').each do |url|
        notifiers << Uvobot::Notifications::SlackNotifier.new(url)
      end
    end

    if ENV['DISCOURSE_URL']
      discourse_client = Uvobot::DiscourseClient.new(
        ENV.fetch('DISCOURSE_URL'),
        ENV.fetch('DISCOURSE_API_KEY'),
        ENV.fetch('DISCOURSE_USER')
      )
      notifiers << Uvobot::Notifications::DiscourseNotifier.new(
        discourse_client,
        ENV.fetch('DISCOURSE_TARGET_CATEGORY'),
        Uvobot::UvoScraper.new
      )
    end

    notifiers << Uvobot::Notifications::ConsoleNotifier.new

    Uvobot::Worker.new(
      Uvobot::UvoScraper.new,
      notifiers
    ).run(Date.today)

  end
end

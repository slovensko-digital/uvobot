# UVObot

Ruby 4.0.9 / Rails 8.1.4.

Notifikácie pre chat www.slack.com a www.discourse.org fórum z Úradu pre verejné obstarávanie o obstarávaniach v IT sektore.

## Vývoj

Požiadavky: Ruby 4.0.9 (pozri `.ruby-version`), PostgreSQL.

```sh
bundle install
bundle exec rspec
```

## Nasadenie cez Docker

Build docker obrazu pomocou `docker build -t my_uvobot .`. Pri spustení kontajnera je potrebné mať nastavené env `RAILS_ENV=production` a `SECRET_KEY_BASE` (inak aplikácia v produkcii nenabehne).

Slack integrácie sa nastavujú cez `UVOBOT_SLACK_WEBHOOK`, kde môže byť viacero URL oddelených čiarkou `,`. Default channel je `#general`, bodkočiarkou `;` za každou URL je možné nastaviť iný channel bez hashtagu `#`. Napr. `https://example.com/my-hook;my-custom-channel,https://example2.com/my-other-hook;my-other-custom-channel`.

Discourse cez `DISCOURSE_URL`, `DISCOURSE_API_KEY`, `DISCOURSE_USER` a `DISCOURSE_TARGET_CATEGORY`. Intregrácie, pre ktoré nie sú nastavené envs, sa nevykonajú a uvobot vypíše nájdené výsledky iba do konzoly.

Čas spustenia `15:00` je možné upraviť v `config/clock.rb`.

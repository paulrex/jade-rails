# Ruby on Rails Integration with Jade

This gem provides integration for Ruby on Rails projects with the [Jade
templating language](http://jade-lang.com/).

## Installing

Add to your Gemfile:

```ruby
gem 'jade-rails', '~> 1.8.0.0'
```

In your `application.js`, require the Jade runtime before any files that include
Jade templates.

```
//= require jade/runtime
```

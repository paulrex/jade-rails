# Ruby on Rails Integration with Jade

This gem provides integration for Ruby on Rails projects with the [Jade
templating language](http://jade-lang.com/).

Combined with the JST engine built in to Sprockets, you can use this gem
to render Jade templates anywhere on the front end of your Rails app.

## Installing

Add to your Gemfile:

```ruby
gem 'jade-rails', '~> 1.9.2.0'
```

In your `application.js`, require the Jade runtime before any files that include
Jade templates.

```
//= require jade/runtime
```

## Configuring

Use `config.jade` in your application or environment files to set compilation
options. These will be passed to the Jade compiler for all your templates.

This gem supports only a subset of the full list of Jade compiler options,
because only some of them make sense for client-side compilation within Rails.

### Available Options

- `pretty`: Add whitespace to the compiled HTML to make it slightly easier to
  read. This defaults to `true` in development and `false` otherwise.

- `self`: Use a `self` namespace to hold locals in compiled templates. This
  defaults to `false` in all environments.

- `compile_debug`: Compile templates with debugging instrumentation. (This is
  passed as `compileDebug` to the Jade compiler.) It defaults to `true` in
  development and `false` otherwise.

- `globals`: This is an array of globals (as strings) that will be made
  available in the local scope of compiled templates. It defaults to `[]`.

In addition, the `filename` of the template being compiled is always passed in
to the Jade compiler options. If `compile_debug` is set to `true`, the filename
will be shown as part of the error output.

See [the official Jade documentation](http://jade-lang.com/api/) for more
details about these options.

## Example

In `config/application.rb`:

```ruby
AmazingProject::Application.configure do
  config.jade.pretty = true
  config.jade.compile_debug = true
  config.jade.globals = ['helpers']
end
```

In `app/assets/javascripts/templates/amazing_template.jst.jade`:

```jade
h1 Jade: A Template Engine
p.lead.
  Jade is a terse and simple templating language with a strong focus on
  performance and powerful features.
```

Then you can render this template anywhere in your JS code:

```javascript
JST['templates/amazing_template']()
```

## Notes

Includes are not supported. Instead, use JST along with Jade's functionality
for unescaped buffered code. For example, to "include" another template named
`includes/header.jst.jade` which renders with no locals, write:

```jade
!= JST['includes/header']()
```

## Running Tests

```bash
bundle exec rake test
```

## Versioning

The `jade-rails` gem version always reflects the version of Jade it contains,
with an additional number for gem-specific changes.

Always check [the Jade change log](http://jade-lang.com/history/) when upgrading.

## Code Status

[![Gem Version](https://badge.fury.io/rb/jade-rails.svg)](http://badge.fury.io/rb/jade-rails)

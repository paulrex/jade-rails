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

See [the official Jade documentation](http://jade-lang.com/api/) for more
details about these options.

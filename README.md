# Sublimaiton Kitchen

## run tests

```
$ bundle exec rake
```

or use Guard

```
$ bundle exec guard
```

## heroku

### ImageMagick

we need at least 6.9.3

`heroku buildpacks:add --index 1 https://github.com/ello/heroku-buildpack-imagemagick`

## Decisions

User 'verification' endpoint overwritten by 'simple_verification' endpoint. See SK-317

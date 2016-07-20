The current format of the `data.json` file is as follows:

```json
{
  'live': true,
  'broadcast': {
    'slug': 'show_slug_here'
  }
}
```

The `live` attribute is a boolean, `true` for if a show is live, `false`
otherwise. The `broadcast` attribute is an object with an attribute `slug`. The
`broadcast.slug` attribute is a string with a short "slug" unique to each show.
The slugs are defined in the `public/shows.json` file.

Your Xana can host its own `data.json` file by launching the web server at start
and putting the file in a web-public folder (like `public/`). You can also
provide an alternate URL for your `data.json` file in the `.env` file.

If you want to remove the functionality provided by `data.json`, you will need
to start by removing the [before create hook][hook] in `suggestion.rb`. To avoid
the "Show Not Listed" message you'll want to remove the suggestion set break in
[`_table_set.haml`][table_set] and [`_bubble_set.haml`][bubble_set].

[hook]: https://github.com/s0ph0s-2/Showbot/blob/master/lib/models/suggestion.rb#L66
[table_set]: https://github.com/s0ph0s-2/Showbot/blob/master/views/suggestion/_table_set.haml#L4
[bubble_set]: https://github.com/s0ph0s-2/Showbot/blob/master/views/suggestion/_bubble_set.haml#L3

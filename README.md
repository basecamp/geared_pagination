# Geared Pagination

Most pagination schemes use a fixed page size. Page 1 returns as many elements as page 2. But that's
frequently not the most sensible way to page through a large recordset when you care about serving the
initial request as quickly as possible. This is particularly the case when using the pagination scheme
in combination with an infinite scrolling UI.

Geared Pagination allows you to define different ratios. By default, we will return 15 elements on page 1,
30 on page 2, 50 on page 3, and 100 from page 4 and forward. This has proven to be a very sensible set of
ratios for much of the Basecamp UIs. But you can of course tweak the ratios, use fewer, or even none at all,
if a certain page calls for a fixed-rate scheme.

On JSON actions that set a page, we'll also automatically set Link and X-Total-Count headers for APIs
to be able to page through a recordset.

## Example

```ruby
class MessagesController < ApplicationController
  def index
    set_page_and_extract_portion_from Message.order(created_at: :desc)
  end
end

# app/views/messages/index.html.erb

Showing page <%= @page.number %> of <%= @page.recordset.page_count %> (<%= @page.recordset.records_count %> total messages):

<%= render @page.records %>

<% if @page.last? %>
  No more pages!
<% else %>
  <%= link_to "Next page", messages_path(page: @page.next_param) %>
<% end %>

```

## Cursor-based pagination

By default, Geared Pagination uses *offset-based pagination*: the `page` query parameter contains the page number. Each page’s records are located using a query with an `OFFSET` clause, like so:

```sql
SELECT *
FROM messages
ORDER BY created_at DESC
LIMIT 30
OFFSET 15
```

You may prefer to use *cursor-based pagination* instead. In cursor-based pagination, the `page` parameter contains a “cursor” describing the last row of the previous page. Each page’s records are located using a query with conditions that only match records after the previous page. For example, if the last record on the previous page had a `created_at` value of `2019-01-24T12:35:26.381Z` and an ID of `7354857`, the current page’s records would be found with a query like this one:

```sql
SELECT *
FROM messages
WHERE (created_at = '2019-01-24T12:35:26.381Z' AND id < 7354857)
OR created_at < '2019-01-24T12:35:26.381Z'
ORDER BY created_at DESC, id DESC
LIMIT 30
```

Geared Pagination supports cursor-based pagination. To use it, pass the `:ordered_by` option to `set_page_and_extract_portion_from` in your controllers. Provide the orders to apply to the paginated relation:

```ruby
set_page_and_extract_portion_from Message.all, ordered_by: { created_at: :desc, id: :desc }
```

Geared Pagination uses the ordered attributes (in the above example, `created_at` and `id`) to generate cursors:

```erb
<%= link_to "Next page", messages_path(page: @page.next_param) %>
<!-- <a href="/messages?page=eyJwYWdlX251...">Next page</a> -->
```

Cursors encode the information Geared Pagination needs to query for the corresponding page’s records: the page number for choosing a page size, and the values of each of the ordered attributes (`created_at` and `id`).

### When should I use cursor-based pagination?

Cursor-based pagination can outperform offset-based pagination when paginating deeply into a large number of records. DBs commonly execute queries with `OFFSET` clauses by counting past `OFFSET` records one at a time, so each page in offset-based pagination takes slightly longer to load than the last. With cursor-based pagination and an appropriate index, the DB can jump directly to the beginning of each page without scanning.

The tradeoff is that Geared Pagination only supports cursor-based pagination on simple relations with simple, column-only orders. Cursor-based pagination also won’t perform better than offset-based pagination without an ordered index. Stick with offset-based pagination if:
* You need complex ordering on a complex relation
* You’re paginating a small and/or bounded number of records

## Caching

To account for the current page in fragment caches, include the `@page` directly.
That includes the current page number and gear ratios.

Fragment caching a message's comments:
```ruby
<% cache [ @message, @page ] do %>
  <%= render @page.records %>
<% end %>
```

NOTE: The page does not include cache keys for all the records. That would require loading all the records,
defeating the purpose of using the cache. Use a parent record, like a message that's touched when
new comments are posted, as the cache key instead.

## ETags

When a controller action sets an ETag and uses geared pagination, the current page and gear ratios are
automatically included in the ETag.

## License
Geared Pagination is released under the [MIT License](https://opensource.org/licenses/MIT).

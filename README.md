# Geared Pagination

Most pagination schemes use a fixed page size. Page 1 returns as many elements as page 2. But that's
frequently not the most sensible way to page through a large collection when you care about serving the
initial request as quickly as possible. This is particularly the case when using the pagination scheme
in combination with an infinite scrolling UI.

Geared Pagination allows you to define different ratios. By default, we will return 15 elements on page 1,
30 on page 2, 50 on page 3, and 100 from page 4 and forward. This has proven to be a very sensible set of
ratios for much of the Basecamp UIs. But you can of course tweak the ratios, use fewer, or even none at all,
if a certain page calls for a fixed-rate scheme.

On json actions that set a page, we'll also automatically set Link and X-Total-Count headers for APIs
to be able to page through a collection.

## Example

```ruby
class MessagesController < ApplicationController
  def index
    @page = current_page_from Message.order(created_at: :desc)
  end
end

# app/views/messages/index.html.erb

Showing page <%= @page.number %> of <%= @page.collection.page_count %> (<%= @page.collection.record_count %> total messages):

<%= render @page.records %>

<% if @page.last? %>
  No more pages!
<% else %> 
  <%= link_to "Next page", messages_path(page: @page.next_number) %>
<% end %>

```

## License
Geared Pagination is released under the [MIT License](https://opensource.org/licenses/MIT).

defmodule PolymorphicProductionsWeb.PostView do
  use PolymorphicProductionsWeb, :view

  def format_date(dt) do
    Timex.format!(dt, "{Mshort} {D}, {YYYY}")
  end

  def render("social.show.html", assigns) do
    {
      :safe,
      """
      <meta property="og:type" content="image/jpeg" />
      <meta property="og:url" content="#{Routes.post_url(assigns[:conn], :show, assigns[:post])}" />
      <meta property="og:title" content="Polymorphic Productions | #{assigns[:post].excerpt} " />
      <meta property="og:description" content="#{assigns[:post].excerpt}" />
      <meta property="og:site_name" content="Polymorphic Productions" />
      <meta name="twitter:site" content="@PolymorphicProd">
      <meta name="twitter:title" content="Polymorphic Productions | #{assigns[:post].title}">
      <meta name="twitter:description" content="#{assigns[:post].excerpt}">
      <meta name="twitter:card" content="summary_large_image">
      <meta name="twitter:widgets:new-embed-design" content="on">
      <meta property="og:image"      content="#{assigns[:post].med_image}" />
      <meta name="twitter:image:src" content="#{assigns[:post].med_image}">
      """
    }
  end

  def time_ago(time) do
    {:ok, relative_str} = time |> Timex.format("{relative}", :relative)

    relative_str
  end

  def parse_tags(content) do
    content
    |> String.replace(~r/#(\w*)/, "<a href='/snapshots/tag/\\1'>#\\1</a>")
  end
end
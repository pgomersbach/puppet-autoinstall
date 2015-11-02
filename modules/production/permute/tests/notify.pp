permute { "Foo":
  resource  => "notify",
  unique    => {
    message => ["foo", "bar", "baz"]
  },
  common => {
    tag  => thing,
  },
}

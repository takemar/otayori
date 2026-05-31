require_relative '../app/models.rb'

Post.source_dir = File.expand_path('../../files/source/', __FILE__)

Tag.create! [
  {
    name: 'Example Tag',
    slug: 'example-tag',
    order: 1,
  },
]

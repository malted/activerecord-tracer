# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "activerecord", "~> 7.1", require: "active_record"
  #gem "arel", "~> 9.0"
  gem 'sqlite3', '~> 1.3', '>= 1.3.11'
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
Arel::Table.engine = ActiveRecord::Base

class Constant < ActiveRecord::Base
  self.table_name = :constants
end

ActiveRecord::Schema.define do
  create_table :constants do |t|
    t.string :name
    t.float :value
  end
end

class Vector3 < ActiveRecord::Base
  self.table_name = :vector3s
end
ActiveRecord::Schema.define do
  create_table :vector3s do |t|
    t.string :name
    t.float :x
    t.float :y
    t.float :z
  end
end

class Sphere < ActiveRecord::Base
  self.table_name = :spheres
  belongs_to :position, class_name: "Vector3"
end
ActiveRecord::Schema.define do
  create_table :spheres do |t|
    t.string :name
    t.references :position, foreign_key: { to_table: :vector3s }
    t.float :radius
  end
end

def let(name, value)
  Constant.create!(name:, value:)
end

def get(name)
  Constant.find_by(name:).value
end

def getv3(name)
  Vector3.find_by(name:)
end

# Image
let :aspect_ratio, 16.0/9.0
let :width, 400
let :height, get(:width) / get(:aspect_ratio)

# Camera
let :viewport_height, 2.0
let :viewport_width, get(:aspect_ratio) * get(:viewport_height)
let :focal_length, 1.0

c = Constant.arel_table
v = Vector3.arel_table
s = Sphere.arel_table

Vector3.create!(name: :origin, x: 0, y: 0, z: 0)
Vector3.create!(name: :horizontal, x: get(:viewport_width), y: 0, z: 0)
Vector3.create!(name: :vertical, x: 0, y: get(:viewport_height), z: 0)
Vector3.create!(
  name: :corner_bottom_left,
  x: Vector3.find_by(name: :origin).x - Vector3.find_by(name: :horizontal).x / 2.0 - Vector3.find_by(name: :vertical).x / 2.0,
  y: Vector3.find_by(name: :origin).y - Vector3.find_by(name: :horizontal).y / 2.0 - Vector3.find_by(name: :vertical).y / 2.0,
  z: Vector3.find_by(name: :origin).z - Vector3.find_by(name: :horizontal).z / 2.0 - Vector3.find_by(name: :vertical).z / 2.0 - get(:focal_length)
)

Sphere.create!(name: :big_sphere, position: Vector3.create!(x: 0.0, y: 0.0, z: -1.0), radius: 0.5)

numbers = Arel::Table.new(:numbers)

recursive_term = Arel::SelectManager.new
recursive_term
  .from(numbers)
  .project(0, 0)
  .union(Arel::SelectManager.new.from(numbers).project(1, 2))

#manager = Arel::SelectManager.new
#manager.with(:recursive).as(recursive_term).from(:final).project(Arel.star)
#puts manager.to_sql

puts "P3"
puts ActiveRecord::Base.connection.select_value(Arel::SelectManager.new.project(Arel::Nodes::NamedFunction.new("PRINTF", [Arel.sql('"%i %i"'), get(:width).to_i, get(:height).to_i])).to_sql
)

#puts ActiveRecord::Base.connection.execute(Arel::SelectManager.new.project('PRINTF("P3")').to_sql)
#puts Arel::SelectManager.new.project("hi").to_sql
#puts ActiveRecord::Base.connection.execute(Arel::SelectManager.new.project("hi").to_sql)

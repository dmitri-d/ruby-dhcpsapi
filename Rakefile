#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/clean'
require 'rake/testtask'
require 'yard'

task default: :test

Rake::TestTask.new do |task|
  task.libs.unshift(File.expand_path('../integration_test', __FILE__))
  task.test_files = FileList['integration_test/**/*_test.rb']
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.options = %w(--embed-mixins --markup=markdown --no-private)
end

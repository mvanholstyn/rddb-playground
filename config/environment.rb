require 'rubygems'
require 'active_support'
require 'pp'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), %w[..])) unless defined? ROOT

$: << File.join(ROOT, %w[vendor gems CouchDb-Ruby src])
require 'couchdb'

$: << File.join(ROOT, %w[vendor gems rddb lib])
require 'rddb'

$: << File.join(ROOT, 'lib')


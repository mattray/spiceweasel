# encoding: UTF-8
#
# Author:: Matt Ray (<matt@getchef.com>)
#
# Copyright:: 2011-2014, Chef Software, Inc <legal@getchef.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "ffi_yajl"

require "spiceweasel/command_helper"

module Spiceweasel
  # manages parsing of Data Bags
  class DataBags
    include CommandHelper

    attr_reader :create, :delete

    def initialize(data_bags = []) # rubocop:disable CyclomaticComplexity
      @create = []
      @delete = []

      return unless data_bags

      Spiceweasel::Log.debug("data bags: #{data_bags}")

      data_bags.each do |data_bag|
        db, items, secret = knife_data_bag_create_delete(data_bag)
        items = invoke_validate_item(db, items, secret)

        items.delete_if { |x| x.include?("*") } # remove wildcards

        items.sort!.uniq!

        data_bag_from_file(db, items, secret)
      end
    end

    def data_bag_from_file(db, items, secret)
      return if items.empty?

      if secret
        create_command("knife data bag#{Spiceweasel::Config[:knife_options]} from file #{db} #{items.join('.json ')}.json --secret-file #{secret}")
      else
        create_command("knife data bag#{Spiceweasel::Config[:knife_options]} from file #{db} #{items.join('.json ')}.json")
      end
    end

    def invoke_validate_item(db, items, secret)
      items = [] if items.nil?
      Spiceweasel::Log.debug("data bag: #{db} #{secret} #{items}")
      items.each do |item|
        Spiceweasel::Log.debug("data bag #{db} item: #{item}")
        if item =~ /\*/ # wildcard support, will fail if directory not present
          files = Dir.glob("data_bags/#{db}/#{item}")
          # remove anything not ending in .json
          files.delete_if { |x| !x.end_with?(".json") }
          items.concat(files.map { |x| x["data_bags/#{db}/".length..-6] })
          Spiceweasel::Log.debug("found files '#{files}' for data bag: #{db} with wildcard #{item}")
          next
        end
        validate_item(db, item) unless Spiceweasel::Config[:novalidation]
      end
      items
    end

    def knife_data_bag_create_delete(data_bag)
      db = data_bag.keys.first
      # check directories
      if !File.directory?("data_bags") && !Spiceweasel::Config[:novalidation]
        STDERR.puts "ERROR: 'data_bags' directory not found, unable to validate or load data bag items"
        exit(-1)
      end

      if !File.directory?("data_bags/#{db}") && !Spiceweasel::Config[:novalidation]
        STDERR.puts "ERROR: 'data_bags/#{db}' directory not found, unable to validate or load data bag items"
        exit(-1)
      end

      create_command("knife data bag#{Spiceweasel::Config[:knife_options]} create #{db}")
      delete_command("knife data bag#{Spiceweasel::Config[:knife_options]} delete #{db} -y")

      items, secret = identify_items_secret(data_bag, db)
      return db, items, secret
    end

    def identify_items_secret(data_bag, db)
      items = nil
      secret = nil
      if data_bag[db]
        items = data_bag[db]["items"]
        secret = data_bag[db]["secret"]
        if secret && !File.exist?(File.expand_path(secret)) && !Spiceweasel::Config[:novalidation]
          STDERR.puts "ERROR: secret key #{secret} not found, unable to load encrypted data bags for data bag #{db}."
          exit(-1)
        end
      end
      return items, secret
    end

    # validate the item to be loaded
    def validate_item(db, item)
      unless File.exist?("data_bags/#{db}/#{item}.json")
        STDERR.puts "ERROR: data bag '#{db}' item '#{item}' file 'data_bags/#{db}/#{item}.json' does not exist"
        exit(-1)
      end
      f = File.read("data_bags/#{db}/#{item}.json")
      begin
        itemfile = JSON.parse(f)
      rescue JSON::ParserError => e # invalid JSON
        STDERR.puts "ERROR: data bag '#{db} item '#{item}' has JSON errors."
        STDERR.puts e.message
        exit(-1)
      end
      # validate the id matches the file name
      item = item.split("/").last if item =~ /\// # pull out directories

      return if item.eql?(itemfile["id"])

      STDERR.puts "ERROR: data bag '#{db}' item '#{item}' listed in the manifest does not match the id '#{itemfile['id']}' within the 'data_bags/#{db}/#{item}.json' file."
      exit(-1)
    end
  end
end

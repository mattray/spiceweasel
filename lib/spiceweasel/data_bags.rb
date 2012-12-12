#
# Author:: Matt Ray (<matt@opscode.com>)
#
# Copyright:: 2011-2012, Opscode, Inc <legal@opscode.com>
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

require 'json'

module Spiceweasel
  class DataBags

    attr_reader :create, :delete

    def initialize(data_bags = [], options = {})
      @create = @delete = ''
      if data_bags
        STDOUT.puts "DEBUG: data bags: #{data_bags}" if Spiceweasel::Config[:debug]
        data_bags.each do |data_bag|
          db = data_bag.keys.first
          #check directories
          if !File.directory?("data_bags") && !Spiceweasel::Config[:novalidation]
            STDERR.puts "ERROR: 'data_bags' directory not found, unable to validate or load data bag items"
            exit(-1)
          end
          if !File.directory?("data_bags/#{db}") && !Spiceweasel::Config[:novalidation]
            STDERR.puts "ERROR: 'data_bags/#{db}' directory not found, unable to validate or load data bag items"
            exit(-1)
          end
          @create += "knife data bag#{options['knife_options']} create #{db}\n"
          @delete += "knife data bag#{options['knife_options']} delete #{db} -y\n"
          if data_bag[db]
            items = data_bag[db]['items']
            secret = data_bag[db]['secret']
            if secret && !File.exists?(secret) && !Spiceweasel::Config[:novalidation]
              STDERR.puts "ERROR: secret key #{secret} not found, unable to load encrypted data bags for data bag #{db}."
              exit(-1)
            end
          end
          items = [] if items.nil?
          STDOUT.puts "DEBUG: data bag: #{db} #{secret} #{items}" if Spiceweasel::Config[:debug]
          while item = items.shift
            STDOUT.puts "DEBUG: data bag #{db} item: #{item}" if Spiceweasel::Config[:debug]
            if item =~ /\*/ #wildcard support, will fail if directory not present
              files = Dir.glob("data_bags/#{db}/*.json")
              items += files.collect {|x| x[x.rindex('/')+1..-6]}
              STDOUT.puts "DEBUG: found items '#{items}' for data bag: #{db}" if Spiceweasel::Config[:debug]
              next
            end
            validateItem(db, item) unless Spiceweasel::Config[:novalidation]
            if secret
              @create += "knife data bag#{options['knife_options']} from file #{db} #{item}.json --secret-file #{secret}\n"
            else
              @create += "knife data bag#{options['knife_options']} from file #{db} #{item}.json\n"
            end
          end
        end
      end
    end

    #validate the item to be loaded
    def validateItem(db, item)
      if !File.exists?("data_bags/#{db}/#{item}.json")
        STDERR.puts "ERROR: data bag '#{db}' item '#{item}' file 'data_bags/#{db}/#{item}.json' does not exist"
        exit(-1)
      end
      f = File.read("data_bags/#{db}/#{item}.json")
      itemfile = JSON.parse(f) #invalid JSON will throw a trace
      #validate the id matches the file name
      if !item.eql?(itemfile['id'])
        STDERR.puts "ERROR: data bag '#{db}' item '#{item}' listed in the manifest does not match the id '#{itemfile['id']}' within the 'data_bags/#{db}/#{item}.json' file."
        exit(-1)
      end
    end

  end
end

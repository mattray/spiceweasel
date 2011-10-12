class Spiceweasel::DataBagList
  def initialize(data_bags = [], options = {})
    @create = @delete = ''
    data_bags.each do |data_bag|
      STDOUT.puts "DEBUG: data bag: #{data_bag.keys[0]}" if DEBUG
      @delete += "knife data bag#{options['knife_options']} delete #{data_bag.keys[0]} -y\n"
      @create += "knife data bag#{options['knife_options']} create #{data_bag.keys[0]}\n"
      items = data_bag[data_bag.keys[0]] || []
      secret = nil
      while item = items.shift
        STDOUT.puts "DEBUG: data bag #{data_bag.keys[0]} item: #{item}" if DEBUG
        if item.start_with?("secret")
          secret = item.split()[1]
          next
        end
        if item =~ /\*/ #wildcard support
          files = Dir.glob("data_bags/#{data_bag.keys[0]}/#{item}.json")
          items += files.collect {|x| x[x.rindex('/')+1..-6]}
          puts items
          next
        end
        if secret
          @create += "knife data bag#{options['knife_options']} from file #{data_bag.keys[0]} data_bags/#{data_bag.keys[0]}/#{item}.json --secret-file #{secret}\n"
        else
          @create += "knife data bag#{options['knife_options']} from file #{data_bag.keys[0]} data_bags/#{data_bag.keys[0]}/#{item}.json\n"
        end
      end
    end
  end

  attr_reader :create, :delete
end

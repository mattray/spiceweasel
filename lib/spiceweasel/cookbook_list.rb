class Spiceweasel::CookbookList
  def initialize(cookbooks = [], options = {})
    @create = @delete = ''
    @cookbooks = []
    if cookbooks
      cookbooks.each do |cookbook|
        cb = cookbook.keys.first
        if cookbook[cb] and cookbook[cb].length > 0
          version = cookbook[cb][0].to_s || ""
          args = cookbook[cb][1] || ""
        end
        STDOUT.puts "DEBUG: cookbook: #{cb} #{version}" if DEBUG
        @delete += "knife cookbook#{options['knife_options']} delete #{cb} #{version} -y\n"
        if File.directory?("cookbooks")
          if version and File.directory?("cookbooks/#{cb}")
            #check metadata.rb for requested version
            metadata = File.open("cookbooks/#{cb}/metadata.rb").grep(/^version/)[0].split()[1].gsub(/"/,'').to_s
            if (metadata != version)
              raise "Invalid version #{version} of '#{cb}' requested, #{metadata} is already in the cookbooks directory."
              exit(-1)
            end
          elsif !File.directory?("cookbooks/#{cb}")
            if SITEINSTALL #use knife cookbook site install
              @create += "knife cookbook#{options['knife_options']} site install #{cb} #{version} #{args}\n"
            else #use knife cookbook site download, untar and then remove the tarball
              @create += "knife cookbook#{options['knife_options']} site download #{cb} #{version} --file cookbooks/#{cb}.tgz #{args}\n"
              @create += "tar -C cookbooks/ -xf cookbooks/#{cb}.tgz\n"
              @create += "rm -f cookbooks/#{cb}.tgz\n"
            end
          end
        else
          STDERR.puts "cookbooks directory not found, validation and downloading skipped"
        end
        @create += "knife cookbook#{options['knife_options']} upload #{cb}\n"

        @cookbooks << cb
      end
    end
  end

  attr_reader :cookbooks, :create, :delete

  def member?(cookbook)
    cookbooks.include?(cookbook)
  end
end

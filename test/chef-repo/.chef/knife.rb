current_dir = File.dirname(__FILE__)
log_level                 :info
log_location              STDOUT
cookbook_path             ["#{current_dir}/../cookbooks"]
encrypted_data_bag_secret ["#{current_dir}/WRONGPASSWORD"]

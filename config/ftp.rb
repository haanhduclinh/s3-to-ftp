module Config
  module Ftp
    module_function

    %i[username password port host].each do |method_name|
      define_method method_name do
        Settings.ftp.send(method_name)
      end
    end
  end
end

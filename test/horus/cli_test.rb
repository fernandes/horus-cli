require 'test_helper'

class Horus::CliTest < Minitest::Test
  include Horus::Helpers

  def test_that_it_has_a_version_number
    assert ::Horus::Cli::VERSION == "0.1.0"
  end

  def test_command_version
    out = get_command_output(['version'])
    assert out == "#{Horus::Cli::Config::COMPANY}-cli #{Horus::Cli::VERSION}\n"
  end

  def test_command_company_options
    out = get_command_output(['company_options'])
    assert out.index('company: ') != nil
    assert out.index('url: ') != nil
  end

  def test_command_list
    do_login
    out = get_command_output(['list','clients'])
    assert out.index("{\"id\"=>\"") != nil
    assert out.index("\"type\"=>\"clients\"") != nil
  end

  def test_command_create
    do_login
    keyname = get_new_key_name("keyname")
    data = '"corporate-name": "Corporate Name", "trade-name": "Trade Name", "key-name": "'+"#{keyname}"+'", "email": "client@example.com"'
    out = get_command_output(['create','clients',data])
    assert out.include?("{\"corporate-name\"=>\"Corporate Name\"")
  end

  def test_command_show
    do_login
    clients = apidata_to_hash(get_command_output(['list','clients']))
    out = get_command_output(['show','clients',clients[0]["id"]])
    assert out.index("{\"id\"=>\"#{clients[0]["id"]}\", \"type\"=>\"clients\", \"corporate-name\"=>\"") != nil
  end

  def test_command_update
    do_login
    clients = apidata_to_hash(get_command_output(['list','clients']))
    client = clients[rand(clients.length-1)]
    newmail = "newclient@#{client["key-name"]}.com"
    out = get_command_output(['update','clients',client["id"],'"email":"'+newmail+'"'])
    assert out.include?('{"id"=>"'+client["id"]+'", "type"=>"clients", "corporate-name"=>"'+client["corporate-name"]+'", "trade-name"=>"'+client["trade-name"]+'", "key-name"=>"'+client["key-name"]+'", "email"=>"'+newmail+'"}')
  end

  def test_command_profile
    do_login
    out = get_command_output(['profile','show'])
    assert out.include?('"type"=>"profile", "email"=>"manager@example.com"')

    out = get_command_output(['profile','update','"first-name":"Test"'])
    assert out.include?('"first-name"=>"Test",')
  end

  def do_login
    login_as('Manager', 'manager@example.com', 'pass1234', Horus::Cli::Config::API_BASE_URL+"oauth/token")
  end

  def apidata_to_hash(apidata)
    array_data = apidata.split("\n")
    results = []
    array_data.each do |data|
      results.push(eval(data))
    end
    results
  end

  def get_new_key_name(keyname)
    alphabet = %w(a b c d e f g h i j k l m n o p q r s t u v x y z)
    clients = apidata_to_hash(get_command_output(['list','clients']))
    count = 0
    clients.each do |client|
      if client["key-name"].include? keyname
        count = count+1
      end
    end
    letters = ''
    wheels = (count/alphabet.length)
    for i in 0..wheels
      position = count-(alphabet.length*wheels)
      letters+=alphabet[position]
    end
    "#{keyname}#{letters}"
  end
end

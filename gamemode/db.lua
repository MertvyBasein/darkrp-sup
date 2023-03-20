rp._Stats = mysql('localhost','root', '', 'database', 3306)
rp._Credits = mysql('localhost','root', '', 'database', 3306)

MySQLite_config = MySQLite_config or {} -- Ignore this line

MySQLite_config.EnableMySQL = true
MySQLite_config.Host = "localhost"
MySQLite_config.Username = "root"

MySQLite_config.Password = ""

MySQLite_config.Database_name = "database"
MySQLite_config.Database_port = 3306
MySQLite_config.Preferred_module = "tmysql4"
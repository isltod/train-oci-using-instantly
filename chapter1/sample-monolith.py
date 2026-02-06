import json
from faker import Faker
from flask import Flask, request
import logging
import pymysql
import mysql.connector


app = Flask(__name__)

logger = logging.getLogger()
logger.setLevel(logging.INFO)

fake = Faker()

# DB 접속 환경
mysql_db_host_ip = "168.107.33.56"
# mysql_db_host_ip = "10.0.0.161"
mysql_db_user_name = "root"
mysql_db_password = "1111"
mysql_db_name = "test"

@app.route('/', methods=['GET'])
def index():
    try:
        # DB 접속
        conn = mysql.connector.connect(
            host=mysql_db_host_ip, 
            user=mysql_db_user_name, 
            password=mysql_db_password, 
            db=mysql_db_name, charset='utf8'
            )
        # 커서 생성
        mysql_cursor = conn.cursor()
        # 사용자 접속 이력을 기록...
        sql = "INSERT INTO users(user_name, job, client_ip, last_conn_date) VALUES(%s, %s, %s, CURRENT_TIMESTAMP)"
        # 이 밑에를 잘 모르겠고...
        mysql_sql_val = (fake.name(), fake.job(), fake.ipv4_private())
        mysql_cursor.execute(sql, mysql_sql_val)

        #최종 접속 사용자를 조회...
        sql = "SELECT user_name, job, client_ip, DATE_FORMAT(last_conn_date, '%Y-%m-%d %T.%f') " \
        "FROM users ORDER BY last_conn_date DESC LIMIT 10"
        mysql_cursor.execute(sql)
        mysql_results = mysql_cursor.fetchall()
        
        # 조회 결과를 JSON으로...
        mysql_result = json.dumps(mysql_results, default=str)

        conn.commit()
        conn.close()
    except Exception as e:
        logger.error("mysql error: could not fetch data")
        logger.error(e)
    
    logger.info("success: querying data succeeded.")
    return mysql_result

@app.route("/hello", methods=['GET'])
def hello():
    return "Hello OCI!"
